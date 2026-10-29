import '../../data/models/create_order_payload.dart';
import '../entities/order_entity.dart';
import '../repositories/order_data_repositories.dart';

class CreateOrderUsecase {
  final OrderDataRepository repository;
  const CreateOrderUsecase(this.repository);

  Future<OrderEntity?> call(CreateOrderPayload payload) async {
    return repository.createOrder(payload);
  }
}
