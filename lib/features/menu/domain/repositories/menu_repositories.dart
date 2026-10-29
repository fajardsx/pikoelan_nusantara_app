import '../../data/models/category_payload.dart';
import '../../data/models/menu_item_payload.dart';
import '../entities/menu_category_entity.dart';
import '../entities/menu_item_entity.dart';

abstract class MenuDataRepository {
  Future<List<MenuCategoryEntity>> getCategories({bool refresh});
  Future<MenuCategoryEntity?> createCategory(CategoryPayload payload);
  Future<MenuCategoryEntity?> updateCategory(int id, CategoryPayload payload);
  Future<void> deleteCategory(int id);

  Future<List<MenuItemEntity>> getMenuItems({int? categoryId, bool refresh});
  Future<MenuItemEntity?> createMenuItem(MenuItemPayload payload);
  Future<MenuItemEntity?> updateMenuItem(int id, MenuItemPayload payload);
  Future<void> deleteMenuItem(int id);
}
