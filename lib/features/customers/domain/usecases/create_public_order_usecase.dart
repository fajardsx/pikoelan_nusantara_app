import 'package:restauran_menu/features/customers/domain/repositories/public_menu_repository.dart';
import 'package:restauran_menu/features/orders/data/models/create_order_payload.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

class CreatePublicOrderUsecase {
  final PublicMenuRepository repository;
  const CreatePublicOrderUsecase(this.repository);
  Future<OrderEntity?> call(String slug, CreateOrderPayload payload) =>
      repository.createPublicOrder(slug, payload);
}
