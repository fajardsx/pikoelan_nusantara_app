import '../repositories/stock_repository.dart';

class DeleteStockItem {
  final StockRepository repository;
  DeleteStockItem(this.repository);

  Future<void> call(int id) => repository.deleteStockItem(id);
}
