import 'package:restauran_menu/features/customers/domain/repositories/public_menu_repository.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

class CancelPublicOrderUsecase {
  final PublicMenuRepository repository;
  const CancelPublicOrderUsecase(this.repository);

  Future<OrderEntity?> call(String slug, String orderNumber) =>
      repository.cancelPublicOrder(slug, orderNumber);
}

