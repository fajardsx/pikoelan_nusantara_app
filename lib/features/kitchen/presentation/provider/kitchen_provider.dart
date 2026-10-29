import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/database/order_repository.dart';
import 'package:restauran_menu/features/kasir/presentation/provider/kasir_provider.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:restauran_menu/features/orders/domain/usecases/update_order_status_usecase.dart';

/// Provider driving the Kitchen Display kanban board. Kitchen staff only care
/// about food-prep progress (Baru -> Proses -> Siap -> Diantar), not
/// payment, so this is intentionally separate from [KasirProvider]. Backed by
/// the same shared [OrderRepository] as Kasir/Waiter/Customer.
enum DashboardStatus { initial, loading, loaded, error }

class KitchenProvider extends ChangeNotifier {
  final GetOrdersUsecase getOrdersUsecase;
  final UpdateOrderStatusUsecase updateOrderStatusUsecase;
  KitchenProvider(
    this.getOrdersUsecase,
    this.updateOrderStatusUsecase,
    this._orderRepository,
  ) {
    _subscription = _orderRepository.watchAll().listen((orders) {
      _orders = orders.where((o) {
        //final created = o.createdAt.toLocal();
        final getIsToday = isToday(
          o.createdAt,
        ); //created.isAfter(start) && created.isBefore(end);
        //debugPrint("order kitchen created $created");
        final statusOk =
            o.status == OrderEntity.statusNew ||
            o.status == OrderEntity.statusProses ||
            o.status == OrderEntity.statusReady;
        return getIsToday && statusOk;
        //return statusOk;
      }).toList();
      notifyListeners();
    });
  }

  final OrderRepository _orderRepository;
  StreamSubscription<List<OrderEntity>>? _subscription;

  DashboardStatus status = DashboardStatus.initial;
  String? errorMessage;

  String currentFilter = '';

  List<OrderEntity> _orders = [];

  List<OrderEntity> get baru =>
      _orders.where((o) => o.status == OrderEntity.statusNew).toList();
  List<OrderEntity> get proses =>
      _orders.where((o) => o.status == OrderEntity.statusProses).toList();
  List<OrderEntity> get siap =>
      _orders.where((o) => o.status == OrderEntity.statusReady).toList();

  Future<void> load({String? filter, bool refresh = true}) async {
    if (filter != null) currentFilter = filter;
    status = DashboardStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await getOrdersUsecase(status: null, refresh: refresh);
      final allOrders = results;
      await _orderRepository.addAll(allOrders);
      status = DashboardStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
    }
    notifyListeners();
  }

  Future<void> startCooking(OrderEntity order) async {
    try {
      status = DashboardStatus.loading;
      await advanceStatus(
        order.id,
        OrderEntity.statusProses,
        order.paymentMethod ?? "",
        order.isPaid,
      );
      await _orderRepository.updateStatus(
        order.orderNumber,
        OrderEntity.statusProses,
      );
      status = DashboardStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
      debugPrint("error : $errorMessage");
    }
    notifyListeners();
  }

  Future<void> markReady(OrderEntity order) async {
    try {
      status = DashboardStatus.loading;
      await advanceStatus(
        order.id,
        OrderEntity.statusReady,
        order.paymentMethod ?? "",
        order.isPaid,
      );
      await _orderRepository.updateStatus(
        order.orderNumber,
        OrderEntity.statusReady,
      );
      status = DashboardStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
      debugPrint("error :` $errorMessage");
    }
    notifyListeners();
  }

  /// Order has been picked up (by waiter) and leaves the kitchen board.
  Future<void> markPickedUp(OrderEntity order) async {
    try {
      status = DashboardStatus.loading;
      await advanceStatus(
        order.id,
        OrderEntity.statusDeliver,
        order.paymentMethod ?? "",
        order.isPaid,
      );
      await _orderRepository.updateStatus(
        order.orderNumber,
        OrderEntity.statusDeliver,
      );
      status = DashboardStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
      debugPrint("error :` $errorMessage");
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
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
