import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/database/order_repository.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/features/customers/presentation/provider/cart_provider.dart';
import 'package:restauran_menu/features/kasir/presentation/widgets/kasir_print.dart';
import 'package:restauran_menu/features/members/domain/entities/member_entity.dart';
import 'package:restauran_menu/features/members/domain/usecases/validate_member_by_phone_usecase.dart';
import 'package:restauran_menu/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:restauran_menu/features/orders/domain/usecases/update_order_status_usecase.dart';

import '../../../admin/presentation/widgets/sales_report.dart';

/// Filter for the "Pesanan Aktif" tabs (Semua / Dine In / Take Away / Delivery).
enum OrderFilter { semua, dineIn, takeAway, delivery }

enum DashboardStatus { initial, loading, loaded, error }

extension OrderFilterLabel on OrderFilter {
  String get label {
    switch (this) {
      case OrderFilter.semua:
        return 'Semua';
      case OrderFilter.dineIn:
        return 'Dine In';
      case OrderFilter.takeAway:
        return 'Take Away';
      case OrderFilter.delivery:
        return 'Delivery';
    }
  }

  String? get orderType {
    switch (this) {
      case OrderFilter.semua:
        return null;
      case OrderFilter.dineIn:
        return OrderEntity.typeDineIn;
      case OrderFilter.takeAway:
        return OrderEntity.typeTakeaway;
      case OrderFilter.delivery:
        return OrderEntity.typeDelivery;
    }
  }
}

/// Provider driving the whole Kasir (POS) dashboard: the active order list,
/// the currently selected order's detail, and its payment panel. Reads and
/// writes go through [OrderRepository] (Hive), which is also watched by
/// Kitchen, Waiter and Customer — so payments processed here are instantly
/// reflected everywhere else too.
class KasirProvider extends ChangeNotifier {
  final GetOrdersUsecase getOrdersUsecase;
  final GetMenuItemsUsecase getMenuItemsUsecase;
  final UpdateOrderStatusUsecase updateOrderStatusUsecase;
  final ValidateMemberByPhoneUsecase validateMemberByPhoneUsecase;

  KasirProvider(
    this.getOrdersUsecase,
    this.getMenuItemsUsecase,
    this.updateOrderStatusUsecase,
    this.validateMemberByPhoneUsecase,
    this._orderRepository,
  ) {
    _subscription = _orderRepository.watchAll().listen(_onOrders);
  }

  final OrderRepository _orderRepository;
  StreamSubscription<List<OrderEntity>>? _subscription;

  DashboardStatus status = DashboardStatus.initial;
  String? errorMessage;

  List<OrderEntity> activeOrders = [];
  List<OrderEntity> history = [];
  String? selectedOrderNumber;
  OrderFilter filter = OrderFilter.semua;
  String currentFilter = '';
  String? paymentMethod;
  int cashReceived = 0;

  List<OrderEntity> recentOrders = [];
  int ordersToday = 0;
  double revenueToday = 0;
  int pendingTodayCount = 0;
  int pendingCount = 0;
  int activeMenuCount = 0;

  /// Filter tanggal aktif untuk query ke API (disamakan dengan AdminProvider).
  /// Null = semua data.
  DateTime? startDateFilter;
  DateTime? endDateFilter;
  bool get hasDateFilter => startDateFilter != null || endDateFilter != null;

  MemberEntity? member;

  SalesReport sales = const SalesReport(
    totalRevenue: 0,
    transactionCount: 0,
    transactionCompleteCount: 0,
    qrisCount: 0,
    qrisTotal: 0,
    cashCount: 0,
    cashTotal: 0,
    transferCount: 0,
    transferTotal: 0,
    topMenuItems: [],
  );

  /// Pesanan aktif khusus hari ini — basis untuk panel kiri + badge tab.
  List<OrderEntity> get todayActiveOrders =>
      activeOrders.where((o) => isToday(o.createdAt)).toList();

  List<OrderEntity> get filteredOrders {
    final today = todayActiveOrders;
    final type = filter.orderType;
    if (type == null) return today;
    return today.where((o) => o.orderType == type).toList();
  }

  OrderEntity? get selectedOrder {
    if (selectedOrderNumber == null) return null;
    final match = activeOrders.where(
      (o) => o.orderNumber == selectedOrderNumber,
    );
    if (match.isEmpty) return null;
    final order = match.first;
    // if (order.paymentMethod != null) {
    //   setPaymentMethod(order.paymentMethod!);
    // }

    return order;
  }

  int get change {
    final total = selectedOrder?.totalAmount.round() ?? 0;
    final diff = cashReceived - total;
    return diff > 0 ? diff : 0;
  }

  bool get canProcessPayment {
    if (selectedOrder == null || paymentMethod == null) return false;
    if (paymentMethod == OrderEntity.payCash) {
      return cashReceived >= (selectedOrder!.totalAmount.round());
    }
    return true;
  }

  Future<void> load({
    String? filter,
    bool refresh = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (filter != null) currentFilter = filter;
    // Simpan filter aktif (null = semua data), pola sama seperti AdminProvider.
    startDateFilter = startDate;
    endDateFilter = endDate;
    status = DashboardStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await getOrdersUsecase(
        status: currentFilter.isEmpty ? null : currentFilter,
        refresh: refresh,
        startDate: startDate,
        endDate: endDate,
      );
      final allOrders = results;
      //debugPrint('KasirProvider.load #$hashCode: API=${allOrders.length}');

      pendingCount = allOrders
          .where((o) => o.status == 'new' || o.status == 'proses')
          .length;

      final todayOrders = allOrders.where((o) => isToday(o.createdAt)).toList();
      // debugPrint(
      //   'KasirProvider.load #$hashCode: today=${todayOrders.length} '
      //   'statuses=${allOrders.map((o) => o.status).toSet()}',
      // );
      ordersToday = todayOrders.length;

      revenueToday = todayOrders
          .where((o) => o.status != OrderEntity.statusCancelled && o.isPaid)
          .fold(0.0, (sum, o) => sum + o.totalAmount);
      pendingTodayCount = todayOrders
          .where((o) => o.status == 'new' || o.status == 'proses')
          .length;
      sales = SalesReport.fromOrders(
        allOrders
            .where((o) => o.status != OrderEntity.statusCancelled && o.isPaid)
            .toList(),
      );
      recentOrders = todayOrders.take(6).toList();

      //activeMenuCount = menuItems.length;
      // Simpan SEMUA order API ke Hive (bukan cuma today) supaya
      // watchAll() + _onOrders() melihat data yang sama.
      await _orderRepository.addAll(allOrders);
      // activeOrders harus dari allOrders — todayOrders hanya untuk statistik.
      _onOrders(allOrders);

      status = DashboardStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
    }
    notifyListeners();
  }

  void _onOrders(List<OrderEntity> orders) {
    activeOrders = orders
        .where(
          (o) =>
              o.status != OrderEntity.statusCompleted &&
              o.status != OrderEntity.statusCancelled,
        )
        .toList();
    history = orders;

    final stillActive = activeOrders.any(
      (o) => o.orderNumber == selectedOrderNumber,
    );
    // Auto-select mengikuti daftar hari ini (yang tampil di panel kiri),
    // bukan order lama dari hari sebelumnya.
    final todayFirst = todayActiveOrders;
    final stillToday = todayFirst.any(
      (o) => o.orderNumber == selectedOrderNumber,
    );
    if (!stillToday) {
      selectedOrderNumber = todayFirst.isNotEmpty
          ? todayFirst.first.orderNumber
          : null;
    } else if (!stillActive) {
      selectedOrderNumber = activeOrders.isNotEmpty
          ? activeOrders.first.orderNumber
          : null;
    }
    notifyListeners();
  }

  void setFilter(OrderFilter f) {
    filter = f;
    notifyListeners();
  }

  void selectOrder({required String orderNumber, String? orderPaymentMethod}) {
    selectedOrderNumber = orderNumber;
    cashReceived = 0;
    paymentMethod = orderPaymentMethod;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  void setCashReceived(int amount) {
    cashReceived = amount;
    notifyListeners();
  }

  Future<void> cancelOrder(OrderEntity order) async {
    await advanceStatus(order.id, 'cancelled', '', false);
    await _orderRepository.cancelOrder(order.orderNumber);
    cashReceived = 0;
    paymentMethod = null;
    notifyListeners();
  }

  /// Marks the selected order as paid & completed (moves it into history
  /// via the shared repository stream).
  Future<void> processPayment() async {
    final order = selectedOrder;
    final method = paymentMethod;
    if (order == null || method == null) return;
    await _orderRepository.markPaid(order.orderNumber, method, complete: false);
    await advanceStatus(order.id, order.status, method, true);
    cashReceived = 0;
    paymentMethod = null;
    notifyListeners();
  }

  Future<void> processComplete() async {
    try {
      final order = selectedOrder;
      final method = order!.paymentMethod;
      if (method == null) return;
      await advanceStatus(order.id, OrderEntity.statusCompleted, method, true);
      await _orderRepository.markPaid(
        order.orderNumber,
        method,
        complete: true,
      );
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
    }
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
      // Pertahankan filter tanggal aktif supaya tidak ke-reset ke semua data.
      await load(startDate: startDateFilter, endDate: endDateFilter);
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
      notifyListeners();
    }
  }

  /// Set filter tanggal lalu reload. Pakai null untuk menampilkan semua data.
  Future<void> setDateFilter(DateTime? start, DateTime? end) =>
      load(startDate: start, endDate: end);

  /// Hapus filter tanggal (kembali ke semua data).
  Future<void> clearDateFilter() => load(startDate: null, endDate: null);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> createOrderFromCart(CartProvider cart) async {}

  // MEMBERSHIP VALIDATE
  Future<void> validateMember({required String phone}) async {
    try {
      status = DashboardStatus.loading;
      notifyListeners();
      final result = await validateMemberByPhoneUsecase(phone);
      if (result.success!) {
        member = result.data!['member'];
        notifyListeners();
      }
    } catch (e, s) {
      member = null;
      AppLog.instance.logError("validate error", e, s);
    } finally {
      status = DashboardStatus.loaded;
      notifyListeners();
    }
  }

  Future<void> resetMember() async {
    try {
      member = null;
      notifyListeners();
    } catch (e, s) {
      member = null;
      AppLog.instance.logError("reset Member error", e, s);
    } finally {}
  }

  Future<void> printReceipt() async {
    try {
      await KasirPrint().printReceipt(selectedOrder);
    } catch (e, s) {
      AppLog.instance.logError("Print Receipt error", e, s);
    } finally {}
  }

  Future<void> printDapurReceipt() async {
    try {
      await KasirPrint().printDapurReceipt(selectedOrder);
    } catch (e, s) {
      AppLog.instance.logError("Print Receipt error", e, s);
    } finally {}
  }
}
