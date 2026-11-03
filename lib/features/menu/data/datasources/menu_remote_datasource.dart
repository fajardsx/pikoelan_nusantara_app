import '../../../../core/configs/api_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../models/categories_response.dart';
import '../models/category_payload.dart';
import '../models/category_response.dart';
import '../models/menu_item_payload.dart';
import '../models/menu_item_response.dart';
import '../models/menu_items_response.dart';

abstract class MenuRemoteDataSource {
  Future<CategoriesResponse> getCategories(bool refresh);
  Future<CategoryResponse> createCategory(CategoryPayload payload);
  Future<CategoryResponse> updateCategory(int id, CategoryPayload payload);
  Future<void> deleteCategory(int id);

  Future<MenuItemsResponse> getMenuItems({int? categoryId, bool refresh});
  Future<MenuItemResponse> createMenuItem(MenuItemPayload payload);
  Future<MenuItemResponse> updateMenuItem(int id, MenuItemPayload payload);
  Future<void> deleteMenuItem(int id);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  @override
  Future<CategoriesResponse> getCategories(bool refresh) async {
    final res = await DioClient.instance.get(
      ApiKeys.menuCategories,
      forceRefresh: refresh,
    );
    return CategoriesResponse.fromJson(res.data);
  }

  @override
  Future<CategoryResponse> createCategory(CategoryPayload payload) async {
    final res = await DioClient.instance.post(
      ApiKeys.menuCategories,
      data: await payload.toFormData(),
    );
    return CategoryResponse.fromJson(res.data);
  }

  @override
  Future<CategoryResponse> updateCategory(
    int id,
    CategoryPayload payload,
  ) async {
    final res = await DioClient.instance.put(
      ApiKeys.menuCategory(id),
      data: await payload.toFormData(),
    );
    return CategoryResponse.fromJson(res.data);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await DioClient.instance.delete(
      ApiKeys.menuCategory(id),
      forceRefresh: true,
    );
  }

  @override
  Future<MenuItemsResponse> getMenuItems({
    int? categoryId,
    bool refresh = false,
  }) async {
    final res = await DioClient.instance.get(
      ApiKeys.menuItems,
      queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
      forceRefresh: refresh,
    );
    return MenuItemsResponse.fromJson(res.data);
  }

  @override
  Future<MenuItemResponse> createMenuItem(MenuItemPayload payload) async {
    final res = await DioClient.instance.post(
      ApiKeys.menuItems,
      data: await payload.toFormData(),
    );
    return MenuItemResponse.fromJson(res.data);
  }

  @override
  Future<MenuItemResponse> updateMenuItem(
    int id,
    MenuItemPayload payload,
  ) async {
    final res = await DioClient.instance.put(
      ApiKeys.menuItem(id),
      data: await payload.toFormData(),
    );
    return MenuItemResponse.fromJson(res.data);
  }

  @override
  Future<void> deleteMenuItem(int id) async {
    await DioClient.instance.delete(ApiKeys.menuItem(id));
  }
}
