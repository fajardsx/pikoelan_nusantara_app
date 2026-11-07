import 'package:flutter/material.dart';
import 'package:restauran_menu/features/stock/data/models/stock_category_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/usecases/create_category.dart';
import 'package:restauran_menu/features/stock/domain/usecases/get_categories.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  final GetCategories getCategories;
  final CreateCategory createCategory;

  CategoryProvider(this.getCategories, this.createCategory);

  CategoryStatus status = CategoryStatus.initial;
  String? errorMessage;
  List<Category> categories = [];
  bool isSubmitting = false;
  String? submitError;

  Future<void> load() async {
    status = CategoryStatus.loading;
    notifyListeners();
    try {
      categories = await getCategories.call();
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
      final category = await createCategory.call(dto);
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
}
