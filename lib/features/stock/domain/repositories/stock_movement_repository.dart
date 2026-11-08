import 'package:restauran_menu/features/stock/data/models/stock_movement_dto.dart';
import 'package:restauran_menu/features/stock/domain/entities/stock_movement.dart';

abstract class StockMovementRepository {
  Future<List<StockMovement>> getStockMovements({
    int? stockItemId,
    String? startDate,
    String? endDate,
  });
  Future<StockMovement> createStockMovement(StockMovementDto dto);
  Future<void> deleteStockMovement(int id);
}
