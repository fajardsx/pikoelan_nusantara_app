import '../repositories/stock_repository.dart';
import '../../data/models/stock_item_dto.dart';
import '../entities/stock_item.dart';

class CreateStockItem {
  final StockRepository repository;
  CreateStockItem(this.repository);

  Future<StockItem> call(StockItemDto dto) => repository.createStockItem(dto);
}
