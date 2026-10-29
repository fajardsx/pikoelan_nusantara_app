import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/database/order_repository.dart';
import 'package:restauran_menu/core/database/table_repository.dart';
import 'package:restauran_menu/features/admin/presentation/provider/admin_provider.dart';
import 'package:restauran_menu/features/customers/domain/entities/cart_item.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:restauran_menu/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:restauran_menu/features/waiters/domain/entities/table.dart';

/// Provider for the Waiter module: orders that the kitchen has marked "Siap"
/// and are waiting to be delivered, a floor overview of table status, and
/// new dine-in orders taken directly by the waiter at the table. Backed by
/// the same shared [OrderRepository] / [TableRepository] as Kasir/Kitchen/
/// Customer, so everything stays in sync in real time.
class WaiterProvider extends ChangeNotifier {
  final GetOrdersUsecase getOrdersUsecase;
  final UpdateOrderStatusUsecase updateOrderStatusUsecase;

  WaiterProvider(
    this._orderRepository,
    this._tableRepository,
    this.getOrdersUsecase,
    this.updateOrderStatusUsecase,
  ) {
    _orderSubscription = _orderRepository.watchAll().listen(_onOrders);
    _tableSubscription = _tableRepository.watchAll().listen(_onTables);
  }

  final OrderRepository _orderRepository;
  final TableRepository _tableRepository;
  StreamSubscription<List<OrderEntity>>? _orderSubscription;
  StreamSubscription<List<RestaurantTable>>? _tableSubscription;

  DashboardStatus status = DashboardStatus.initial;
  String? errorMessage;

  String currentFilter = '';

  /// Order numbers taken by this waiter session.
  final Set<String> _myOrderNumbers = {};
  List<OrderEntity> _allOrders = [];

  List<OrderEntity> readyOrders = [];
  List<RestaurantTable> tables = [];
  List<OrderEntity> myOrders = [];

  int get occupiedCount =>
      tables.where((t) => t.status == TableStatus.terisi).length;
  int get availableCount =>
      tables.where((t) => t.status == TableStatus.kosong).length;
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

  void _onOrders(List<OrderEntity> orders) {
    _allOrders = orders;
    readyOrders = orders
        .where(
          (o) => o.status == OrderEntity.statusReady && isToday(o.createdAt),
        )
        .toList();
    myOrders = orders
        .where((o) => o.source == "waiter" && isToday(o.createdAt))
        .toList();
    notifyListeners();
  }

  void _onTables(List<RestaurantTable> t) {
    tables = t;
    notifyListeners();
  }

  /// Records a new dine-in order taken by the waiter at [tableNumber] and
  /// marks that table as occupied.
  Future<void> takeOrder({
    required int tableNumber,
    required List<CartItem> items,
    int? guestCount,
    String? customerName,
    String? notes,
  }) async {
    final orderNumber = await _orderRepository.createOrder(
      tableNumber: tableNumber,
      orderType: OrderEntity.typeDineIn,
      items: items,
      customerName: customerName,
      notes: notes,
    );
    _myOrderNumbers.add(orderNumber);
    await _tableRepository.occupyTable(
      tableNumber,
      orderNumber: orderNumber,
      guestCount: guestCount,
    );
    myOrders = _allOrders.where((o) => o.source.contains("waiter")).toList();
    notifyListeners();
  }

  /// Records a new takeaway order taken by the waiter without occupying
  /// any table. Used by "Buat Pesanan" from the My Orders tab.
  Future<void> takeTakeawayOrder({
    required List<CartItem> items,
    String? customerName,
    String? notes,
  }) async {
    final orderNumber = await _orderRepository.createOrder(
      tableNumber: null,
      orderType: OrderEntity.typeTakeaway,
      items: items,
      customerName: customerName,
      notes: notes,
    );
    _myOrderNumbers.add(orderNumber);
    myOrders = _allOrders.where((o) => o.source.contains("waiter")).toList();
    notifyListeners();
  }

  /// Waiter has delivered the order to its table; it leaves the ready list.
  Future<void> deliverOrder(OrderEntity order) async {
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
  }

  /// Marks a table as empty again (e.g. after the guest has paid & left).
  Future<void> clearTable(int tableNumber) =>
      _tableRepository.clearTable(tableNumber);
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
      status = DashboardStatus.error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _tableSubscription?.cancel();
    super.dispose();
  }
}
