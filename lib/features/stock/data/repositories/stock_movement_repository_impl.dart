import '../datasources/remote/stock_movement_remote_data_source.dart';
import '../models/stock_movement_dto.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_movement_repository.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  final StockMovementRemoteDataSource remote;

  StockMovementRepositoryImpl({required this.remote});

  @override
  Future<List<StockMovement>> getStockMovements({
    int? stockItemId,
    String? startDate,
    String? endDate,
  }) async {
    return await remote.fetchStockMovements(
      stockItemId: stockItemId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<StockMovement> createStockMovement(StockMovementDto dto) async {
    return await remote.createStockMovement(dto);
  }

  @override
  Future<void> deleteStockMovement(int id) async {
    return await remote.deleteStockMovement(id);
  }
}
