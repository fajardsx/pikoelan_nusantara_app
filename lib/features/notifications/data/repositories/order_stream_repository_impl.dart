import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/order_stream_event.dart';
import '../../domain/entities/order_stream_stats.dart';
import '../../domain/repositories/order_stream_repository.dart';
import '../datasources/order_stream_remote_datasource.dart';
import '../models/order_stream_message_model.dart';

class OrderStreamRepositoryImpl implements OrderStreamRepository {
  OrderStreamRepositoryImpl(this._remoteDataSource);

  final OrderStreamRemoteDataSource _remoteDataSource;

  @override
  Stream<OrderStreamEvent> watchOrders({required String jwt}) {
    return _remoteDataSource.watchOrders(jwt: jwt).map(_toEvent);
  }

  @override
  Future<void> disconnect() => _remoteDataSource.disconnect();

  OrderStreamEvent _toEvent(OrderStreamMessageModel message) {
    final receivedAt = DateTime.now();

    switch (message.transport) {
      case OrderStreamTransport.open:
        return OrderStreamEvent(
          type: OrderStreamEventType.connected,
          receivedAt: receivedAt,
        );
      case OrderStreamTransport.reconnecting:
        return OrderStreamEvent(
          type: OrderStreamEventType.reconnecting,
          receivedAt: receivedAt,
          attempt: message.attempt,
          message: message.retryDelay == null
              ? 'Menyambung ulang...'
              : 'Menyambung ulang dalam ${message.retryDelay!.inSeconds}s',
        );
      case OrderStreamTransport.closed:
        return OrderStreamEvent(
          type: OrderStreamEventType.closed,
          receivedAt: receivedAt,
          message: message.reason ?? 'Koneksi realtime ditutup.',
        );
      case OrderStreamTransport.error:
        final fatal = _isFatalStatus(message.statusCode);
        return OrderStreamEvent(
          type: fatal
              ? OrderStreamEventType.failed
              : OrderStreamEventType.error,
          receivedAt: receivedAt,
          status: null,
          message: fatal
              ? 'Stream ditolak server (HTTP ${message.statusCode}).'
              : message.errorMessage ?? 'Koneksi realtime bermasalah.',
        );
      case OrderStreamTransport.message:
        return _toMessageEvent(message, receivedAt);
    }
  }

  OrderStreamEvent _toMessageEvent(
    OrderStreamMessageModel message,
    DateTime receivedAt,
  ) {
    final eventName = (message.event ?? '').trim().toLowerCase();
    final payload = message.payload;
    final orderMap = _extractOrderMap(payload);
    final statsMap = _extractStatsMap(payload, eventName);
    final status = _extractStatus(payload, orderMap);
    final orderNumber = _extractOrderNumber(payload, orderMap);
    final type = _eventType(eventName, statsMap, orderMap, orderNumber);

    final parsedOrder = _orderFrom(orderMap);
    final safeOrder = type == OrderStreamEventType.orderCreated
        ? parsedOrder
        : (_isFullOrder(orderMap) ? parsedOrder : null);

    return OrderStreamEvent(
      type: type,
      receivedAt: receivedAt,
      order: safeOrder,
      orderNumber: orderNumber,
      status: status,
      stats: statsMap == null ? null : OrderStreamStats.fromJson(statsMap),
      rawEvent: message.event ?? message.rawData,
    );
  }

  static bool _isFatalStatus(int? statusCode) {
    return statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 404;
  }
}

OrderStreamEventType _eventType(
  String eventName,
  Map<String, dynamic>? statsMap,
  Map<String, dynamic>? orderMap,
  String? orderNumber,
) {
  if (eventName.contains('connect')) return OrderStreamEventType.connected;
  if (eventName.contains('ping') ||
      eventName.contains('heartbeat') ||
      eventName.contains('keepalive')) {
    return OrderStreamEventType.heartbeat;
  }
  if (_isStatsEventName(eventName) || statsMap != null) {
    return OrderStreamEventType.stats;
  }
  if (eventName.contains('create') || eventName.contains('new')) {
    return OrderStreamEventType.orderCreated;
  }
  if (eventName.contains('order') ||
      eventName.contains('status') ||
      eventName.contains('payment') ||
      eventName.contains('cancel')) {
    return OrderStreamEventType.orderUpdated;
  }
  if (orderMap != null || orderNumber != null) {
    return OrderStreamEventType.orderUpdated;
  }
  return OrderStreamEventType.unknown;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

Map<String, dynamic>? _extractOrderMap(Map<String, dynamic>? payload) {
  if (payload == null) return null;

  final direct =
      _asMap(payload['order']) ??
      _firstOrderMap(payload['orders']) ??
      _firstOrderMap(payload['data']);
  if (direct != null) return direct;

  final data = _asMap(payload['data']);
  if (data != null) {
    final nested = _asMap(data['order']) ?? _firstOrderMap(data['orders']);
    if (nested != null) return nested;
    if (_looksLikeOrder(data)) return data;
  }

  if (_looksLikeOrder(payload)) return payload;
  return null;
}

Map<String, dynamic>? _firstOrderMap(Object? value) {
  if (value is! List) return null;
  for (final item in value) {
    final map = _asMap(item);
    if (map != null && _looksLikeOrder(map)) return map;
  }
  return null;
}

bool _looksLikeOrder(Map<String, dynamic> json) {
  return json.containsKey('orderNumber') ||
      json.containsKey('order_number') ||
      json.containsKey('orderNo') ||
      json.containsKey('order_no') ||
      (json.containsKey('id') && json.containsKey('status'));
}

String? _extractOrderNumber(
  Map<String, dynamic>? payload,
  Map<String, dynamic>? orderMap,
) {
  final data = _asMap(payload?['data']);
  final candidates = <Object?>[
    orderMap?['orderNumber'],
    orderMap?['order_number'],
    orderMap?['orderNo'],
    orderMap?['order_no'],
    orderMap?['number'],
    payload?['orderNumber'],
    payload?['order_number'],
    payload?['orderNo'],
    payload?['order_no'],
    data?['orderNumber'],
    data?['order_number'],
    data?['orderNo'],
  ];
  for (final value in candidates) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

String? _extractStatus(
  Map<String, dynamic>? payload,
  Map<String, dynamic>? orderMap,
) {
  final data = _asMap(payload?['data']);
  final candidates = <Object?>[
    orderMap?['status'],
    orderMap?['orderStatus'],
    payload?['status'],
    payload?['newStatus'],
    payload?['new_status'],
    payload?['orderStatus'],
    payload?['order_status'],
    data?['status'],
    data?['newStatus'],
    data?['new_status'],
  ];
  for (final value in candidates) {
    if (value is String && value.trim().isNotEmpty) {
      return normalizeOrderStatus(value);
    }
  }
  return null;
}

Map<String, dynamic>? _extractStatsMap(
  Map<String, dynamic>? payload,
  String eventName,
) {
  if (payload == null) return null;

  final direct = _asMap(payload['stats']);
  if (direct != null) return direct;

  final data = _asMap(payload['data']);
  final nested = _asMap(data?['stats']);
  if (nested != null) return nested;

  if (_isStatsEventName(eventName)) return data ?? payload;
  return null;
}

/// Cocokkan nama event statistik secara utuh, supaya `order.status`
/// tidak salah dikenali sebagai event `stats` (substring "stat").
bool _isStatsEventName(String eventName) {
  if (eventName.isEmpty) return false;
  for (final token in eventName.split(RegExp(r'[^a-z0-9]+'))) {
    if (token == 'stat' || token == 'stats' || token.startsWith('statistic')) {
      return true;
    }
  }
  return false;
}

OrderEntity? _orderFrom(Map<String, dynamic>? json) {
  if (json == null) return null;
  final entity = OrderEntity.fromJson(json);
  if (entity.orderNumber.isEmpty && entity.id <= 0) return null;
  return entity;
}

bool _isFullOrder(Map<String, dynamic>? json) {
  if (json == null) return false;

  final items = json['items'] ?? json['orderItems'] ?? json['order_items'];
  if (items is List && items.isNotEmpty) return true;

  final total = json['totalAmount'] ?? json['total_amount'] ?? json['total'];
  if (total is num && total > 0) return true;

  return false;
}
