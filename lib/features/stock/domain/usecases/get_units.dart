import 'package:restauran_menu/features/stock/domain/entities/unit.dart';
import 'package:restauran_menu/features/stock/domain/repositories/stock_repository.dart';

class GetUnits {
  final StockRepository repository;
  GetUnits(this.repository);

  Future<List<Unit>> call() => repository.getUnits();
}
