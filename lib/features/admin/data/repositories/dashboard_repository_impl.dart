import 'package:image_picker/image_picker.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_payment_entity.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

import '../../domain/entities/tenant_entity.dart';
import '../../domain/repositories/dashboard_repositories.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/tenant_payload.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<TenantEntity?> getMyTenant() async {
    final res = await remoteDataSource.getMyTenant();
    return res.data;
  }

  @override
  Future<TenantEntity?> updateMyTenant({
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
    TenantPaymentEntity? tenantPayment,
  }) async {
    final res = await remoteDataSource.updateMyTenant(
      TenantPayload(
        name: name,
        slug: slug,
        address: address,
        phone: phone,
        email: email,
        logoUrl: logoUrl,
        logoFile: logoFile,
        qrisUrl: qrisUrl,
        qrisFile: qrisFile,
        rekening: rekening,
        tenantPayment: tenantPayment,
      ),
    );
    return res.data;
  }

  @override
  Future<List<OrderEntity>> getOrders({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final res = await remoteDataSource.getOrders(
      startDate: startDate,
      endDate: endDate,
    );
    return res.data ?? [];
  }

  @override
  Future<List<MenuItemEntity>> getMenuItems({bool? available}) async {
    final res = await remoteDataSource.getMenuItems(available: available);
    return res.data ?? [];
  }
}
