import 'package:equatable/equatable.dart';

/// Ringkasan statistik order dari event `stats` pada stream SSE.
class OrderStreamStats extends Equatable {
  const OrderStreamStats({
    this.totalOrders,
    this.newOrders,
    this.preparingOrders,
    this.readyOrders,
    this.deliveredOrders,
    this.completedOrders,
    this.cancelledOrders,
    this.revenueToday,
    this.raw = const <String, dynamic>{},
  });

  factory OrderStreamStats.fromJson(Map<String, dynamic> json) {
    return OrderStreamStats(
      totalOrders: _readInt(json, const [
        'totalOrders',
        'total_orders',
        'total',
      ]),
      newOrders: _readInt(json, const [
        'newOrders',
        'new_orders',
        'pendingOrders',
        'pending_orders',
        'baru',
      ]),
      preparingOrders: _readInt(json, const [
        'preparingOrders',
        'preparing_orders',
        'proses',
        'processOrders',
      ]),
      readyOrders: _readInt(json, const [
        'readyOrders',
        'ready_orders',
        'siap',
      ]),
      deliveredOrders: _readInt(json, const [
        'deliveredOrders',
        'delivered_orders',
        'deliverOrders',
        'diantar',
      ]),
      completedOrders: _readInt(json, const [
        'completedOrders',
        'completed_orders',
        'selesai',
      ]),
      cancelledOrders: _readInt(json, const [
        'cancelledOrders',
        'cancelled_orders',
        'canceledOrders',
        'dibatalkan',
      ]),
      revenueToday: _readDouble(json, const [
        'revenueToday',
        'revenue_today',
        'todayRevenue',
        'today_revenue',
        'omzetHariIni',
        'omzet',
      ]),
      raw: Map<String, dynamic>.unmodifiable(json),
    );
  }

  final int? totalOrders;
  final int? newOrders;
  final int? preparingOrders;
  final int? readyOrders;
  final int? deliveredOrders;
  final int? completedOrders;
  final int? cancelledOrders;
  final double? revenueToday;

  /// Payload asli, untuk field statistik yang belum dipetakan.
  final Map<String, dynamic> raw;

  bool get isEmpty => raw.isEmpty;

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    totalOrders,
    newOrders,
    preparingOrders,
    readyOrders,
    deliveredOrders,
    completedOrders,
    cancelledOrders,
    revenueToday,
  ];
}
