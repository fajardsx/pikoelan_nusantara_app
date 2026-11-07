import 'package:restauran_menu/features/stock/data/models/stock_category_dto.dart';
import 'package:restauran_menu/features/stock/data/models/stock_unit_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/category.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';

import '../../domain/entities/stock_item.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/remote/stock_remote_data_source.dart';
import '../models/stock_item_dto.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remote;

  StockRepositoryImpl({required this.remote});

  @override
  Future<List<StockItem>> getStockItems({
    int? page,
    int? limit,
    String? search,
    int? categoryId,
    int? unitId,
    bool? lowStock,
  }) async {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    if (limit != null) query['limit'] = limit.toString();
    if (search != null) query['search'] = search;
    if (categoryId != null) query['categoryId'] = categoryId.toString();
    if (unitId != null) query['unitId'] = unitId.toString();
    if (lowStock != null) query['lowStock'] = lowStock.toString();
    return await remote.fetchStockItems(query: query);
  }

  @override
  Future<StockItem> createStockItem(StockItemDto dto) async =>
      await remote.createStockItem(dto);

  @override
  Future<StockItem> updateStockItem(int id, StockItemDto dto) async =>
      await remote.updateStockItem(id, dto);

  @override
  Future<void> deleteStockItem(int id) async =>
      await remote.deleteStockItem(id);

  @override
  Future<Unit> createUnit(StockUnitDto dto) async => await remote.createUnit(dto);

  @override
  Future<List<Unit>> getUnits() async => await remote.fetchUnits();

  @override
  Future<Category> createCategory(StockCategoryDto dto) async =>
      await remote.createCategory(dto);

  @override
  Future<List<Category>> getCategories() async => await remote.fetchCategories();
}
