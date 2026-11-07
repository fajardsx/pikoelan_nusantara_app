import '../repositories/stock_repository.dart';
import '../../data/models/stock_unit_dto.dart';

class DeleteUnit {
  final StockRepository repository;
  DeleteUnit(this.repository);

  Future<void> call(int id) => repository.deleteUnit(id);
}
