import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

class SalesReport {
  final double totalRevenue;
  final int transactionCount;
  final int transactionCompleteCount;
  final int qrisCount;
  final double qrisTotal;
  final int cashCount;
  final double cashTotal;
  final int transferCount;
  final double transferTotal;
  final List<MapEntry<String, int>> topMenuItems;

  const SalesReport({
    required this.totalRevenue,
    required this.transactionCount,
    required this.transactionCompleteCount,
    required this.qrisCount,
    required this.qrisTotal,
    required this.cashCount,
    required this.cashTotal,
    required this.transferCount,
    required this.transferTotal,
    required this.topMenuItems,
  });

  int get averagePerTransaction =>
      transactionCount == 0 ? 0 : (totalRevenue / transactionCount).round();

  factory SalesReport.fromOrders(List<OrderEntity> orders) {
    var totalRevenue = 0.0;
    var qrisCount = 0;
    var qrisTotal = 0.0;
    var cashCount = 0;
    var cashTotal = 0.0;
    var transferCount = 0;
    var transferTotal = 0.0;
    var totalTransactionComplete = 0;

    final quantityByMenu = <String, int>{};

    for (final order in orders) {
      if (order.isPaid) {
        if (order.status == OrderEntity.statusCompleted) {
          totalTransactionComplete += 1;
        }
        totalRevenue += order.totalAmount;
        if (order.isQris) {
          qrisCount++;
          qrisTotal += order.totalAmount;
        } else if (order.isCash) {
          cashCount++;
          cashTotal += order.totalAmount;
        } else if (order.isTransfer) {
          transferCount++;
          transferTotal += order.totalAmount;
        }
        for (final item in order.items) {
          quantityByMenu.update(
            item.itemName,
            (qty) => qty + item.quantity,
            ifAbsent: () => item.quantity,
          );
        }
      }
    }

    final topMenuItems = quantityByMenu.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SalesReport(
      totalRevenue: totalRevenue,
      transactionCount: orders.length,
      transactionCompleteCount: totalTransactionComplete,
      qrisCount: qrisCount,
      qrisTotal: qrisTotal,
      cashCount: cashCount,
      cashTotal: cashTotal,
      transferCount: transferCount,
      transferTotal: transferTotal,
      topMenuItems: topMenuItems.take(5).toList(),
    );
  }
}
