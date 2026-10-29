import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/database/category_repository.dart';
import 'package:restauran_menu/core/database/menu_repository.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/services/app_log.dart';

import '../../data/models/category_payload.dart';
import '../../data/models/menu_item_payload.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/create_menu_item_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/delete_menu_item_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_menu_items_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/update_menu_item_usecase.dart';

enum MenuStatus { initial, loading, loaded, error }

class MenuProvider extends ChangeNotifier {
  final GetCategoriesUsecase getCategoriesUsecase;
  final CreateCategoryUsecase createCategoryUsecase;
  final UpdateCategoryUsecase updateCategoryUsecase;
  final DeleteCategoryUsecase deleteCategoryUsecase;
  final GetMenuItemsUsecase getMenuItemsUsecase;
  final CreateMenuItemUsecase createMenuItemUsecase;
  final UpdateMenuItemUsecase updateMenuItemUsecase;
  final DeleteMenuItemUsecase deleteMenuItemUsecase;

  MenuProvider(
    this.getCategoriesUsecase,
    this.createCategoryUsecase,
    this.updateCategoryUsecase,
    this.deleteCategoryUsecase,
    this.getMenuItemsUsecase,
    this.createMenuItemUsecase,
    this.updateMenuItemUsecase,
    this.deleteMenuItemUsecase,
  );

  MenuStatus status = MenuStatus.initial;
  String? errorMessage;

  List<MenuCategoryEntity> categories = [];
  List<MenuItemEntity> items = [];
  int? selectedCategoryId;

  // status submit dipisah dari status memuat daftar, supaya form tidak
  // ikut "loading" tiap kali form dibuka
  bool isSubmitting = false;
  String? submitError;

  List<MenuItemEntity> get filteredItems {
    if (selectedCategoryId == null) return items;
    return items.where((i) => i.categoryId == selectedCategoryId).toList();
  }

  Future<void> load({bool refresh = false}) async {
    status = MenuStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        getCategoriesUsecase(refresh: refresh),
        getMenuItemsUsecase(refresh: refresh),
      ]);
      categories = results[0] as List<MenuCategoryEntity>;
      items = results[1] as List<MenuItemEntity>;
      if (refresh) {
        await sl<CategoryRepository>().reset();
        await sl<MenuRepository>().reset();
      }

      await sl<CategoryRepository>().addAll(categories);
      await sl<MenuRepository>().addAll(items);

      status = MenuStatus.loaded;
    } catch (e, s) {
      errorMessage = e.toString();
      AppLog.instance.logError("load error : $errorMessage", e, s);
      status = MenuStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void refresh() {
    load(refresh: true);
  }

  void selectCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<bool> createCategory(CategoryPayload payload) => _runSubmit(() async {
    final result = await Future.wait([
      createCategoryUsecase(payload),
      load(refresh: true),
    ]);
  });

  Future<bool> updateCategory(int id, CategoryPayload payload) =>
      _runSubmit(() async {
        await Future.wait([
          updateCategoryUsecase(id, payload),
          load(refresh: true),
        ]);
      });

  Future<bool> deleteCategory(int id) => _runSubmit(() async {
    await deleteCategoryUsecase(id);
    if (selectedCategoryId == id) selectedCategoryId = null;
    await load(refresh: true);
  });

  Future<bool> createMenuItem(MenuItemPayload payload) => _runSubmit(() async {
    await createMenuItemUsecase(payload);
    await load(refresh: true);
  });

  Future<bool> updateMenuItem(int id, MenuItemPayload payload) =>
      _runSubmit(() async {
        await updateMenuItemUsecase(id, payload);
        await load(refresh: true);
      });

  Future<bool> deleteMenuItem(int id) => _runSubmit(() async {
    await deleteMenuItemUsecase(id);
    await load(refresh: true);
  });

  /// Bungkus semua aksi tulis (create/update/delete) supaya perilaku
  /// isSubmitting/submitError-nya konsisten, tidak perlu diulang di tiap method.
  Future<bool> _runSubmit(Future<void> Function() action) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();
    try {
      await action();
      isSubmitting = false;
      return true;
    } catch (e, s) {
      isSubmitting = false;
      submitError = e.toString();
      AppLog.instance.logError("submiterror $submitError", e, s);
      return false;
    } finally {
      notifyListeners();
    }
  }
}
