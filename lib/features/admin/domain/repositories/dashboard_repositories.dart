import 'package:image_picker/image_picker.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_payment_entity.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

import '../entities/tenant_entity.dart';

abstract class DashboardRepository {
  Future<TenantEntity?> getMyTenant();
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
  });
  Future<List<OrderEntity>> getOrders({DateTime? startDate, DateTime? endDate});
  Future<List<MenuItemEntity>> getMenuItems({bool? available});
}
