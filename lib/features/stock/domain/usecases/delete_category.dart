import '../repositories/stock_repository.dart';

class DeleteCategory {
  final StockRepository repository;
  DeleteCategory(this.repository);

  Future<void> call(int id) => repository.deleteCategory(id);
}
