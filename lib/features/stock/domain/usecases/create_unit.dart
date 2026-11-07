import 'package:restauran_menu/features/stock/domain/repositories/stock_repository.dart';
import 'package:restauran_menu/features/stock/data/models/stock_unit_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/unit.dart';

class CreateUnit {
  final StockRepository repository;
  CreateUnit(this.repository);

  Future<Unit> call(StockUnitDto dto) => repository.createUnit(dto);
}
