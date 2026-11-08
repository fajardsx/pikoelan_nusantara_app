import 'package:restauran_menu/features/stock/domain/repositories/stock_movement_repository.dart';

class DeleteStockMovement {
  final StockMovementRepository repository;
  DeleteStockMovement(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteStockMovement(id);
  }
}
