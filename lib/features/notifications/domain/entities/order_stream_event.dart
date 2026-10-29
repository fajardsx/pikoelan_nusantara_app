import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/order_entity.dart';
import 'order_stream_role.dart';
import 'order_stream_stats.dart';

/// Jenis event bisnis dari stream order.
enum OrderStreamEventType {
  connected,
  reconnecting,
  orderCreated,
  orderUpdated,
  stats,
  heartbeat,
  unknown,
  error,
  failed,
  closed,
}

/// Satu event order yang sudah dipetakan dari frame SSE.
class OrderStreamEvent extends Equatable {
  const OrderStreamEvent({
    required this.type,
    required this.receivedAt,
    this.order,
    this.orderNumber,
    this.status,
    this.stats,
    this.rawEvent,
    this.message,
    this.attempt,
  });

  final OrderStreamEventType type;
  final DateTime receivedAt;

  /// Order lengkap (jika payload memuat data order yang cukup).
  final OrderEntity? order;

  /// Nomor order untuk event parsial (mis. hanya perubahan status).
  final String? orderNumber;

  /// Status ternormalisasi (`new`, `proses`, `ready`, `deliver`, dst).
  final String? status;

  final OrderStreamStats? stats;
  final String? rawEvent;
  final String? message;
  final int? attempt;

  bool get isOrderEvent =>
      type == OrderStreamEventType.orderCreated ||
      type == OrderStreamEventType.orderUpdated;

  bool get isConnectionEvent =>
      type == OrderStreamEventType.connected ||
      type == OrderStreamEventType.reconnecting ||
      type == OrderStreamEventType.error ||
      type == OrderStreamEventType.failed ||
      type == OrderStreamEventType.closed;

  /// Filter ringan per dashboard supaya kitchen tidak memproses event
  /// `deliver`/`completed` yang bukan bagiannya.
  bool isRelevantFor(OrderStreamRole role) {
    if (!isOrderEvent) return true;
    if (role != OrderStreamRole.kitchen) return true;

    final normalized = status == null ? null : normalizeOrderStatus(status!);
    if (normalized == null) return true;
    return normalized == OrderEntity.statusNew ||
        normalized == OrderEntity.statusProses ||
        normalized == OrderEntity.statusReady;
  }

  @override
  List<Object?> get props => [
    type,
    order,
    orderNumber,
    status,
    stats,
    rawEvent,
    message,
    attempt,
  ];
}

/// Menyamakan status backend (Indonesia/Inggris) ke kode kanonik aplikasi.
String normalizeOrderStatus(String status) {
  switch (status.trim().toLowerCase()) {
    case 'baru':
    case 'new':
      return OrderEntity.statusNew;
    case 'diproses':
    case 'proses':
    case 'processing':
    case 'preparing':
    case 'prepared':
      return OrderEntity.statusProses;
    case 'siap':
    case 'ready':
      return OrderEntity.statusReady;
    case 'diantar':
    case 'deliver':
    case 'delivering':
    case 'delivered':
      return OrderEntity.statusDeliver;
    case 'selesai':
    case 'completed':
    case 'complete':
    case 'done':
      return OrderEntity.statusCompleted;
    case 'dibatalkan':
    case 'batal':
    case 'cancelled':
    case 'canceled':
      return OrderEntity.statusCancelled;
    default:
      return status.trim().toLowerCase();
  }
}
