import 'package:restauran_menu/features/stock/data/models/stock_movement_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/stock_movement.dart';
import 'package:restauran_menu/features/stock/domain/repositories/stock_movement_repository.dart';

class CreateStockMovement {
  final StockMovementRepository repository;
  CreateStockMovement(this.repository);

  Future<StockMovement> call(StockMovementDto dto) async {
    return await repository.createStockMovement(dto);
  }
}
