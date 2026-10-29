import 'dart:async';
import 'dart:io';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/database/order_repository.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/customers/presentation/provider/cart_provider.dart';
import 'package:restauran_menu/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:restauran_menu/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:restauran_menu/shared/utils/currency_formatter.dart';

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

  KasirProvider(
    this.getOrdersUsecase,
    this.getMenuItemsUsecase,
    this.updateOrderStatusUsecase,
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
      debugPrint(
        'KasirProvider.load #$hashCode: today=${todayOrders.length} '
        'statuses=${allOrders.map((o) => o.status).toSet()}',
      );
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

  /// TODO: implement actual printing logic using a thermal printer SDK.
  /// Print receipt using a Bluetooth thermal printer (ESC/POS).
  Future<void> printReceipt() async {
    final order = selectedOrder;
    if (order == null) return;

    try {
      // Bluetooth MAC address of the printer (replace with your device)
      final prefs = SharedPrefServices.pref;
      final paperSize = prefs.getString(SettingsKeys.paperSize) ?? '58';
      String printerMac = prefs.getString(SettingsKeys.printerMac) ?? '';

      // Connect
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: printerMac,
      );
      if (!result) {
        throw Exception('Failed to connect: $result');
      }
      List<int> bytes = [];
      // Build ticket with esc_pos_utils_plus
      final profile = await CapabilityProfile.load();
      final generator = Generator(
        paperSize == "58" ? PaperSize.mm58 : PaperSize.mm80,
        profile,
      );

      bytes += generator.reset();

      final ByteData data = await rootBundle.load(
        'assets/images/printicon.png',
      );
      final Uint8List bytesImg = data.buffer.asUint8List();
      img.Image? image = img.decodeImage(bytesImg);
      final resizedImage = img.copyResize(
        image!,
        width: image.width ~/ 1.3,
        height: image.height ~/ 1.3,
        interpolation: img.Interpolation.nearest,
      );
      final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
      bytes += bytesimg;
      bytes += generator.feed(1);
      bytes += generator.text(
        Consts.appName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.text(
        prefs.getString(SettingsKeys.restaurantAddress) ?? '',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        prefs.getString(SettingsKeys.restaurantPhone) ?? '',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      bytes += generator.row([
        PosColumn(
          text: 'Date',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Cashier',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: order.createdAt.toLocal().toString().split('.').first,
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: sl<AuthProvider>().user!.name,
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(
          text: 'No. Order',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Customer Name',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: order.orderNumber,
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: order.customerName ?? "",
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
      bytes += generator.hr();

      // Items (adjust fields as needed)
      for (var item in order.items) {
        final name = item.itemName;
        final qty = item.quantity;
        final price = item.price;
        bytes += generator.row([
          PosColumn(
            text: name,
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '${qty}x',
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: formatRupiah(price * qty),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
      bytes += generator.text(
        'Total: ${formatRupiah(order.total)}',
        styles: const PosStyles(align: PosAlign.right, bold: true),
      );
      bytes += generator.hr();
      bytes += generator.text(
        'Payment Method',
        styles: const PosStyles(align: PosAlign.left, bold: true),
      );
      bytes += generator.text(
        'Metode: ${order.paymentLabel}',
        styles: const PosStyles(align: PosAlign.left),
      );
      bytes += generator.hr();
      bytes += generator.text(
        'Thank you for your order!',
        styles: const PosStyles(
          align: PosAlign.center,
          fontType: PosFontType.fontA,
        ),
      );
      bytes += generator.hr();
      bytes += generator.feed(2);
      bytes += generator.cut();

      // Send bytes to printer
      //final bytes = await testTicket();
      await PrintBluetoothThermal.writeBytes(bytes);
      await PrintBluetoothThermal.disconnect;
    } catch (e, s) {
      // UI can catch & show error via snackbar if desired
      AppLog.instance.logError('Gagal koneksi: $e', e, s);
    }
  }

  Future<List<int>> testTicket({String optionprinttype = "58"}) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      optionprinttype == "58" ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );
    bytes += generator.reset();

    final ByteData data = await rootBundle.load('assets/images/printicon.png');
    final Uint8List bytesImg = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytesImg);

    if (Platform.isIOS) {
      final resizedImage = img.copyResize(
        image!,
        width: image.width ~/ 1.3,
        height: image.height ~/ 1.3,
        interpolation: img.Interpolation.nearest,
      );
      final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
    }

    bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
    );
    bytes += generator.text(
      'Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ',
      styles: const PosStyles(codeTable: 'CP1252'),
    );
    bytes += generator.text(
      'Special 2: blåbærgrød',
      styles: const PosStyles(codeTable: 'CP1252'),
    );

    bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    bytes += generator.text(
      'Reverse text',
      styles: const PosStyles(reverse: true),
    );
    bytes += generator.text(
      'Underlined text',
      styles: const PosStyles(underline: true),
      linesAfter: 1,
    );
    bytes += generator.text(
      'Align left',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Align center',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Align right',
      styles: const PosStyles(align: PosAlign.right),
      linesAfter: 1,
    );

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));
    bytes += generator.qrcode('example.com');

    bytes += generator.text(
      'Text size 50%',
      styles: const PosStyles(fontType: PosFontType.fontB),
    );
    bytes += generator.text(
      'Text size 100%',
      styles: const PosStyles(fontType: PosFontType.fontA),
    );
    bytes += generator.text(
      'Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.feed(2);
    return bytes;
  }
}
