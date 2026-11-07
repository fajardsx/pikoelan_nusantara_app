import '../repositories/stock_repository.dart';
import '../entities/stock_item.dart';

class GetStockItems {
  final StockRepository repository;
  GetStockItems(this.repository);

  Future<List<StockItem>> call({int? page, int? limit, String? search, int? categoryId, int? unitId, bool? lowStock}) {
    return repository.getStockItems(
      page: page,
      limit: limit,
      search: search,
      categoryId: categoryId,
      unitId: unitId,
      lowStock: lowStock,
    );
  }
}
