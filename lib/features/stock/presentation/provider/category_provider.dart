import 'package:flutter/material.dart';
import 'package:restauran_menu/features/stock/data/models/stock_category_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/usecases/create_category.dart';
import 'package:restauran_menu/features/stock/domain/usecases/delete_category.dart';
import 'package:restauran_menu/features/stock/domain/usecases/get_categories.dart';
import 'package:restauran_menu/features/stock/domain/usecases/update_category.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  final GetCategories getCategoriesUsecase;
  final CreateCategory createCategoryUsecase;
  final DeleteCategory deleteCategoryUsecase;
  final UpdateCategory updateCategoryUsecase;

  CategoryProvider(
    this.getCategoriesUsecase,
    this.createCategoryUsecase,
    this.deleteCategoryUsecase,
    this.updateCategoryUsecase,
  );

  CategoryStatus status = CategoryStatus.initial;
  String? errorMessage;
  List<Category> categories = [];
  bool isSubmitting = false;
  String? submitError;

  Future<void> load() async {
    status = CategoryStatus.loading;
    notifyListeners();
    try {
      categories = await getCategoriesUsecase.call();
      status = CategoryStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = CategoryStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addCategory(StockCategoryDto dto) async {
    isSubmitting = true;

    submitError = null;
    notifyListeners();
    try {
      final category = await createCategoryUsecase.call(dto);
      categories.add(category);
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      submitError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete Category
  Future<bool> removeCategory(int id) async => await _runSubmit(() async {
    await deleteCategoryUsecase.call(id);
    categories.removeWhere((c) => c.id == id);
  });

  // Update Category
  Future<bool> updateCategory(int id, StockCategoryDto dto) async =>
      await _runSubmit(() async {
        final upd = await updateCategoryUsecase.call(id, dto);
        final idx = categories.indexWhere((c) => c.id == id);
        if (idx != -1) categories[idx] = upd;
      });

  Category? getCategoriById(int id) {
    final category = categories.firstWhere(
      (u) => u.id == id,
      orElse: () => Category(id: 0, name: '-'),
    );
    return category;
  }

  Future<bool> _runSubmit(Future<void> Function() action) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();
    try {
      await action();
      isSubmitting = false;
      return true;
    } catch (e) {
      isSubmitting = false;
      submitError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }
}
