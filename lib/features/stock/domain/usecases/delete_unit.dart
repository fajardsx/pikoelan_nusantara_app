import '../repositories/stock_repository.dart';

class DeleteUnit {
  final StockRepository repository;
  DeleteUnit(this.repository);

  Future<void> call(int id) => repository.deleteUnit(id);
}
