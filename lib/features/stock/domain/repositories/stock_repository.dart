import 'package:restauran_menu/features/stock/data/models/stock_unit_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';

import '../../data/models/stock_category_dto.dart';
import '../../data/models/stock_item_dto.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/stock_item.dart';

abstract class StockRepository {
  Future<List<StockItem>> getStockItems({
    int? page,
    int? limit,
    String? search,
    int? categoryId,
    int? unitId,
    bool? lowStock,
  });
  Future<StockItem> createStockItem(StockItemDto dto);
  Future<StockItem> updateStockItem(int id, StockItemDto dto);
  Future<void> deleteStockItem(int id);
  Future<Unit> createUnit(StockUnitDto dto);
  Future<List<Unit>> getUnits();
  Future<List<Category>> getCategories();
  Future<Category> createCategory(StockCategoryDto dto);
  Future<void> deleteCategory(int id);
  Future<Category> updateCategory(int id, StockCategoryDto dto);
  Future<void> deleteUnit(int id);
  Future<Unit> updateUnit(int id, StockUnitDto dto);
}
