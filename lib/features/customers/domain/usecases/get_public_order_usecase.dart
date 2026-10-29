import 'package:restauran_menu/features/customers/domain/repositories/public_menu_repository.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

class GetPublicOrderUsecase {
  final PublicMenuRepository repository;
  const GetPublicOrderUsecase(this.repository);

  Future<List<OrderEntity>> call(String slug, {String? orderNumber}) =>
      repository.getPublicOrders(slug, orderNumber: orderNumber);
}
