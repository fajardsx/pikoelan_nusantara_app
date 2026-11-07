import 'package:restauran_menu/features/stock/domain/entities/unit.dart';

import '../../data/models/stock_unit_dto.dart';
import '../repositories/stock_repository.dart';

class UpdateUnit {
  final StockRepository repository;
  UpdateUnit(this.repository);

  Future<Unit> call(int id, StockUnitDto dto) => repository.updateUnit(id, dto);
}
