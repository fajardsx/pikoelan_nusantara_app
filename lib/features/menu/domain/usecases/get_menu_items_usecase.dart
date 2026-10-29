import '../entities/menu_item_entity.dart';
import '../repositories/menu_repositories.dart';

class GetMenuItemsUsecase {
  final MenuDataRepository repository;
  const GetMenuItemsUsecase(this.repository);

  Future<List<MenuItemEntity>> call({int? categoryId, bool refresh = false}) =>
      repository.getMenuItems(categoryId: categoryId, refresh: refresh);
}
