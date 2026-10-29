import '../entities/order_entity.dart';
import '../repositories/order_data_repositories.dart';

class GetOrdersUsecase {
  final OrderDataRepository repository;
  const GetOrdersUsecase(this.repository);

  Future<List<OrderEntity>> call({
    String? status,
    bool refresh = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return repository.getOrders(
      status: status,
      refresh: refresh,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
