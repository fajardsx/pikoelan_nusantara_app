import 'package:restauran_menu/features/customers/data/models/public_menu_response.dart';
import 'package:restauran_menu/features/orders/data/models/create_order_payload.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

abstract class PublicMenuRepository {
  Future<PublicMenuData> getPublicMenu(String slug, {bool forceRefresh = false});
  Future<OrderEntity?> createPublicOrder(String slug, CreateOrderPayload payload);
  Future<List<OrderEntity>> getPublicOrders(String slug, {String? orderNumber});
  Future<OrderEntity?> cancelPublicOrder(String slug, String orderNumber);
}
