import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_entity.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_payment_entity.dart';
import 'package:restauran_menu/features/admin/domain/usecases/get_my_tenant_usecase.dart';
import 'package:restauran_menu/features/admin/domain/usecases/update_my_tenant_usecase.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';
import 'package:restauran_menu/features/orders/domain/usecases/get_orders_usecase.dart';

import '../widgets/sales_report.dart';

enum DashboardStatus { initial, loading, loaded, error }

class AdminProvider extends ChangeNotifier {
  final GetMyTenantUsecase getMyTenantUsecase;
  final GetOrdersUsecase getOrdersUsecase;
  final UpdateMyTenantUsecase updateMyTenantUsecase;
  //final GetMenuItemsUsecase getMenuItemsUsecase;

  AdminProvider(
    this.getMyTenantUsecase,
    this.getOrdersUsecase,
    this.updateMyTenantUsecase,
    //this.getMenuItemsUsecase,
  );

  DashboardStatus status = DashboardStatus.initial;
  String? errorMessage;

  TenantEntity? tenant;
  bool isUpdatingTenant = false;
  String? updateTenantError;
  List<OrderEntity> recentOrders = [];
  DateTime? startDateFilter;
  DateTime? endDateFilter;
  bool get hasDateFilter => startDateFilter != null || endDateFilter != null;
  int ordersToday = 0;
  double revenueToday = 0;
  int pendingTodayCount = 0;
  int pendingCount = 0;
  int activeMenuCount = 0;

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

  Future<void> load({DateTime? startDate, DateTime? endDate}) async {
    status = DashboardStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      // Simpan filter aktif (null = semua data).
      startDateFilter = startDate;
      endDateFilter = endDate;

      final results = await Future.wait([
        getMyTenantUsecase(),
        getOrdersUsecase(startDate: startDate, endDate: endDate, refresh: true),
        //getMenuItemsUsecase(available: true),
      ]);

      tenant = results[0] as TenantEntity?;

      final allOrders = results[1] as List<OrderEntity>;
      //final menuItems = results[2] as List;

      pendingCount = allOrders
          .where((o) => o.status == 'new' || o.status == 'proses')
          .length;
      debugPrint("tenant $tenant");
      final now = DateTime.now();
      final todayOrders = allOrders.where(
        (o) =>
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day,
      );

      ordersToday = todayOrders.length;
      revenueToday = todayOrders
          .where((o) => o.status != 'cancelled' && o.isPaid)
          .fold(0.0, (sum, o) => sum + o.totalAmount);
      pendingTodayCount = todayOrders
          .where((o) => o.status == 'new' || o.status == 'proses')
          .length;
      sales = SalesReport.fromOrders(
        allOrders.where((o) => o.status != 'cancelled').toList(),
      );
      //recentOrders = allOrders.take(6).toList();
      //activeMenuCount = menuItems.length;
      debugPrint("adminProvider : $tenant!");
      await initLocalMyTenant(tenant!);
      status = DashboardStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = DashboardStatus.error;
    }
    notifyListeners();
  }

  /// Update data tenant (nama/slug) milik user yang sedang login.
  /// Mengembalikan `true` jika berhasil, `false` jika gagal
  /// (lihat [updateTenantError] untuk pesannya).
  ///
  /// [logoFile] adalah file baru dari `_pickImage` (XFile image_picker).
  /// Kalau tidak null, datasource mengirim `multipart/form-data` (field
  /// `logo`); kalau null, hanya [logoUrl] yang dikirim sebagai JSON.
  Future<bool> updateMyTenant({
    required String name,
    String? slug,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    XFile? logoFile,
    String? qrisUrl,
    XFile? qrisFile,
    String? rekening,
    String? bankAccountName,
    String? phoneConfirmation,
    String? deliveryDescription,
  }) async {
    isUpdatingTenant = true;
    updateTenantError = null;
    notifyListeners();

    try {
      debugPrint(
        "updateMyTenant ${sl<AuthProvider>().user!.tenantId}, $qrisUrl, $bankAccountName, $rekening, $deliveryDescription, $phoneConfirmation",
      );
      final payments = TenantPaymentEntity(
        tenantId: sl<AuthProvider>().user!.tenantId!,
        qrisUrl: qrisUrl,
        bankAccountName: bankAccountName,
        bankAccountNumber: rekening,
        deliveryDescription: deliveryDescription,
        phoneConfirmation: phoneConfirmation,
      );

      final updated = await updateMyTenantUsecase(
        name: name.trim(),
        slug: slug?.trim(),
        address: address?.trim(),
        phone: phone?.trim(),
        email: email?.trim(),
        logoUrl: logoUrl?.trim(),
        logoFile: logoFile,
        qrisUrl: qrisUrl?.trim(),
        qrisFile: qrisFile,
        rekening: rekening?.trim(),
        tenantPayment: payments,
      );
      // Backend bisa mengembalikan tenant baru, atau null tapi tetap sukses.
      // Kalau null, update state lokal secara optimistis agar UI langsung segar.
      if (updated != null) {
        tenant = updated;
      } else if (tenant != null) {
        tenant = tenant!.copyWith(
          name: name.trim(),
          address: address?.trim(),
          phone: phone?.trim(),
          email: email?.trim(),
          logoUrl: logoUrl?.trim(),
          qrisUrl: qrisUrl?.trim(),
          rekening: rekening?.trim(),
          tenantPayment: payments,
        );
      }
      isUpdatingTenant = false;
      notifyListeners();
      return true;
    } catch (e) {
      isUpdatingTenant = false;
      updateTenantError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Future<void> initLocalMyTenant(TenantEntity tenant) async {
  //   final prefs = SharedPrefServices.pref;
  //   await prefs.setString(SettingsKeys.restaurantName, tenant.name.trim());
  //   await prefs.setString(
  //     SettingsKeys.restaurantAddress,
  //     tenant.address!.trim(),
  //   );
  //   await prefs.setString(SettingsKeys.restaurantPhone, tenant.phone!.trim());
  //   await prefs.setString(SettingsKeys.restaurantLogo, tenant.logoUrl!);
  //   await prefs.setString(SettingsKeys.restaurantQris, tenant.qrisUrl!);
  // }
}
