import 'package:restauran_menu/features/stock/domain/entities/stock_movement.dart';
import 'package:restauran_menu/features/stock/domain/repositories/stock_movement_repository.dart';

class GetStockMovements {
  final StockMovementRepository repository;
  GetStockMovements(this.repository);

  Future<List<StockMovement>> call({
    int? stockItemId,
    String? startDate,
    String? endDate,
  }) async {
    return await repository.getStockMovements(
      stockItemId: stockItemId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
