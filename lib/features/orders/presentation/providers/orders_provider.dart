import 'package:flutter/foundation.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_orders_usecase.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/update_order_status_usecase.dart';

enum OrdersStatus { initial, loading, loaded, error }

class OrdersProvider extends ChangeNotifier {
  final GetOrdersUsecase getOrdersUsecase;
  final UpdateOrderStatusUsecase updateOrderStatusUsecase;

  OrdersProvider(this.getOrdersUsecase, this.updateOrderStatusUsecase);

  OrdersStatus status = OrdersStatus.initial;
  String? errorMessage;
  List<OrderEntity> orders = [];
  String currentFilter = '';

  Future<void> load({String? status}) async {
    if (status != null) currentFilter = status;
    this.status = OrdersStatus.loading;
    notifyListeners();

    try {
      orders = await getOrdersUsecase(
        status: currentFilter.isEmpty ? null : currentFilter,
      );
      this.status = OrdersStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      this.status = OrdersStatus.error;
    }
    notifyListeners();
  }

  Future<void> advanceStatus(
    int orderId,
    String nextStatus,
    String paymentMethod,
    bool paymentConfirmation,
  ) async {
    try {
      await updateOrderStatusUsecase(
        orderId,
        nextStatus,
        paymentMethod,
        paymentConfirmation,
      );
      await load();
    } catch (e) {
      errorMessage = e.toString();
      status = OrdersStatus.error;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(int orderId) =>
      advanceStatus(orderId, 'cancelled', '', false);
}
