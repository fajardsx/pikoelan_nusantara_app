import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/database/order_repository.dart';
import '../../domain/entities/order_stream_event.dart';
import '../../domain/entities/order_stream_role.dart';
import '../../domain/entities/order_stream_stats.dart';
import '../../domain/usecases/watch_order_stream_usecase.dart';

enum OrderStreamConnectionStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  failed,
  stopped,
}

/// Menjaga satu koneksi SSE per dashboard staf dan menulis order yang masuk
/// ke [OrderRepository] (Hive). Karena Kasir/Kitchen/Waiter mem-watch box Hive
/// yang sama, perubahan langsung tampil tanpa polling ulang.
class OrderStreamProvider extends ChangeNotifier {
  OrderStreamProvider(this._watchOrderStreamUsecase, this._orderRepository);

  final WatchOrderStreamUsecase _watchOrderStreamUsecase;
  final OrderRepository _orderRepository;

  StreamSubscription<OrderStreamEvent>? _subscription;
  int _generation = 0;
  bool _disposed = false;

  OrderStreamRole? role;
  OrderStreamConnectionStatus connectionStatus =
      OrderStreamConnectionStatus.idle;
  String? errorMessage;
  OrderStreamEvent? lastEvent;
  OrderStreamStats? stats;
  DateTime? connectedAt;
  DateTime? lastEventAt;
  int reconnectAttempt = 0;
  int receivedEvents = 0;
  int syncedOrders = 0;

  bool get isConnected =>
      connectionStatus == OrderStreamConnectionStatus.connected;

  String get statusLabel {
    switch (connectionStatus) {
      case OrderStreamConnectionStatus.idle:
        return 'Menunggu';
      case OrderStreamConnectionStatus.connecting:
        return 'Menghubungkan';
      case OrderStreamConnectionStatus.connected:
        return 'Realtime aktif';
      case OrderStreamConnectionStatus.reconnecting:
        return 'Menyambung ulang';
      case OrderStreamConnectionStatus.failed:
        return 'Terputus';
      case OrderStreamConnectionStatus.stopped:
        return 'Berhenti';
    }
  }

  /// Mulai stream untuk [role]. Aman dipanggil berulang (idempoten).
  void start({
    required OrderStreamRole role,
    bool force = false,
    bool clearStats = false,
  }) {
    if (_disposed) return;
    if (!force && _subscription != null) return;

    _generation++;
    final previous = _subscription;
    _subscription = null;
    if (previous != null) unawaited(previous.cancel());

    this.role = role;
    connectionStatus = OrderStreamConnectionStatus.connecting;
    errorMessage = null;
    reconnectAttempt = 0;
    if (clearStats) stats = null;
    notifyListeners();

    final generation = _generation;
    _subscription = _watchOrderStreamUsecase().listen(
      (event) {
        if (_disposed || generation != _generation) return;
        unawaited(_handleEvent(event));
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed || generation != _generation) return;
        connectionStatus = OrderStreamConnectionStatus.failed;
        errorMessage = error.toString();
        notifyListeners();
      },
      onDone: () {
        if (_disposed || generation != _generation) return;
        if (connectionStatus != OrderStreamConnectionStatus.failed) {
          connectionStatus = OrderStreamConnectionStatus.stopped;
        }
        notifyListeners();
      },
    );
  }

  void restart() {
    final currentRole = role;
    if (currentRole == null) return;
    start(role: currentRole, force: true);
  }

  Future<void> stop() async {
    _generation++;
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    await _watchOrderStreamUsecase.disconnect();
    if (!_disposed) {
      connectionStatus = OrderStreamConnectionStatus.stopped;
      notifyListeners();
    }
  }

  Future<void> _handleEvent(OrderStreamEvent event) async {
    lastEvent = event;
    lastEventAt = event.receivedAt;

    switch (event.type) {
      case OrderStreamEventType.connected:
        connectionStatus = OrderStreamConnectionStatus.connected;
        connectedAt = event.receivedAt;
        reconnectAttempt = 0;
        errorMessage = null;
      case OrderStreamEventType.reconnecting:
        connectionStatus = OrderStreamConnectionStatus.reconnecting;
        reconnectAttempt = event.attempt ?? reconnectAttempt + 1;
      case OrderStreamEventType.error:
        errorMessage = event.message ?? 'Koneksi realtime bermasalah.';
      case OrderStreamEventType.failed:
        connectionStatus = OrderStreamConnectionStatus.failed;
        errorMessage = event.message ?? 'Koneksi realtime gagal.';
      case OrderStreamEventType.closed:
        connectionStatus = OrderStreamConnectionStatus.stopped;
        errorMessage = event.message;
      case OrderStreamEventType.stats:
        if (event.stats != null) {
          stats = event.stats;
          receivedEvents++;
        }
      case OrderStreamEventType.orderCreated:
      case OrderStreamEventType.orderUpdated:
        final currentRole = role ?? OrderStreamRole.kasir;
        if (event.isRelevantFor(currentRole)) {
          await _syncOrder(event);
        }
      case OrderStreamEventType.heartbeat:
      case OrderStreamEventType.unknown:
        break;
    }

    if (!_disposed) notifyListeners();
  }

  Future<void> _syncOrder(OrderStreamEvent event) async {
    final order = event.order;
    final orderNumber = (event.orderNumber ?? order?.orderNumber ?? '').trim();
    if (orderNumber.isEmpty) return;

    if (order != null && order.orderNumber.trim().isNotEmpty) {
      await _orderRepository.addItem(order);
    } else {
      final status = event.status;
      if (status == null) return;
      await _orderRepository.updateStatus(orderNumber, status);
    }

    receivedEvents++;
    syncedOrders++;
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) unawaited(subscription.cancel());
    unawaited(_watchOrderStreamUsecase.disconnect());
    super.dispose();
  }
}
