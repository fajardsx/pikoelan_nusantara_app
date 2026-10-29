import '../entities/order_menu_item_entity.dart';
import '../repositories/order_data_repositories.dart';

class GetAvailableMenuItemsUsecase {
  final OrderDataRepository repository;
  const GetAvailableMenuItemsUsecase(this.repository);

  Future<List<OrderMenuItemEntity>> call() async {
    return repository.getAvailableMenuItems();
  }
}
