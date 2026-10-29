import 'package:restauran_menu/features/customers/data/datasources/public_menu_remote_datasource.dart';
import 'package:restauran_menu/features/customers/data/models/public_menu_response.dart';
import 'package:restauran_menu/features/customers/domain/repositories/public_menu_repository.dart';
import 'package:restauran_menu/features/orders/data/models/create_order_payload.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

class PublicMenuRepositoryImpl implements PublicMenuRepository {
  final PublicMenuRemoteDataSource remote;
  PublicMenuRepositoryImpl(this.remote);

  @override
  Future<PublicMenuData> getPublicMenu(String slug, {bool forceRefresh = false}) async {
    final res = await remote.getPublicMenu(slug, forceRefresh: forceRefresh);
    return res.data ?? const PublicMenuData();
  }

  @override
  Future<OrderEntity?> createPublicOrder(String slug, CreateOrderPayload payload) async {
    final res = await remote.createPublicOrder(slug, payload);
    return res.data;
  }

  @override
  Future<List<OrderEntity>> getPublicOrders(String slug, {String? orderNumber}) async {
    final res = await remote.getPublicOrders(slug, orderNumber: orderNumber);
    return res.data ?? [];
  }

  @override
  Future<OrderEntity?> cancelPublicOrder(String slug, String orderNumber) async {
    final res = await remote.cancelPublicOrder(slug, orderNumber);
    return res.data;
  }
}
