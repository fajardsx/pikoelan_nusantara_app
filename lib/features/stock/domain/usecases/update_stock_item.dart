import '../repositories/stock_repository.dart';
import '../../data/models/stock_item_dto.dart';
import '../entities/stock_item.dart';

class UpdateStockItem {
  final StockRepository repository;
  UpdateStockItem(this.repository);

  Future<StockItem> call(int id, StockItemDto dto) => repository.updateStockItem(id, dto);
}
