import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/menu_repositories.dart';
import '../datasources/menu_remote_datasource.dart';
import '../models/category_payload.dart';
import '../models/menu_item_payload.dart';

class MenuRepositoryImpl implements MenuDataRepository {
  final MenuRemoteDataSource remoteDataSource;
  MenuRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MenuCategoryEntity>> getCategories({bool refresh = false}) async {
    final res = await remoteDataSource.getCategories(refresh);
    return res.data ?? [];
  }

  @override
  Future<MenuCategoryEntity?> createCategory(CategoryPayload payload) async {
    final res = await remoteDataSource.createCategory(payload);
    return res.data;
  }

  @override
  Future<MenuCategoryEntity?> updateCategory(
    int id,
    CategoryPayload payload,
  ) async {
    final res = await remoteDataSource.updateCategory(id, payload);
    return res.data;
  }

  @override
  Future<void> deleteCategory(int id) => remoteDataSource.deleteCategory(id);

  @override
  Future<List<MenuItemEntity>> getMenuItems({
    int? categoryId,
    bool refresh = false,
  }) async {
    final res = await remoteDataSource.getMenuItems(
      categoryId: categoryId,
      refresh: refresh,
    );
    return res.data ?? [];
  }

  @override
  Future<MenuItemEntity?> createMenuItem(MenuItemPayload payload) async {
    final res = await remoteDataSource.createMenuItem(payload);
    return res.data;
  }

  @override
  Future<MenuItemEntity?> updateMenuItem(
    int id,
    MenuItemPayload payload,
  ) async {
    final res = await remoteDataSource.updateMenuItem(id, payload);
    return res.data;
  }

  @override
  Future<void> deleteMenuItem(int id) => remoteDataSource.deleteMenuItem(id);
}
