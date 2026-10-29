import '../entities/order_entity.dart';
import '../repositories/order_data_repositories.dart';

class UpdateOrderStatusUsecase {
  final OrderDataRepository repository;
  const UpdateOrderStatusUsecase(this.repository);

  Future<OrderEntity?> call(
    int orderId,
    String status,
    String paymentMethod,
    bool paymentConfirmation,
  ) async {
    return repository.updateOrderStatus(
      orderId,
      status,
      paymentMethod,
      paymentConfirmation,
    );
  }
}
