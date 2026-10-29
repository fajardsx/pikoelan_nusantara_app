import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

import '../repositories/dashboard_repositories.dart';

class GetOrdersAdminUsecase {
  final DashboardRepository repository;
  const GetOrdersAdminUsecase(this.repository);

  Future<List<OrderEntity>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return repository.getOrders(startDate: startDate, endDate: endDate);
  }
}
