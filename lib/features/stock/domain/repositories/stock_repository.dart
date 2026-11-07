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
  // New unit methods
  Future<List<Unit>> getUnits();
  Future<Unit> createUnit(StockUnitDto dto);
  // New category methods
  Future<List<Category>> getCategories();
  Future<Category> createCategory(StockCategoryDto dto);
}
