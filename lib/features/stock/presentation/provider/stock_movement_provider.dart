import 'package:flutter/foundation.dart';

import '../../data/models/stock_movement_dto.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/create_stock_movement.dart';
import '../../domain/usecases/delete_stock_movement.dart';
import '../../domain/usecases/get_stock_movements.dart';

enum StockMovementStatus { initial, loading, loaded, error }

class StockMovementProvider extends ChangeNotifier {
  final GetStockMovements getStockMovements;
  final CreateStockMovement createStockMovement;
  final DeleteStockMovement deleteStockMovement;

  StockMovementProvider(
    this.getStockMovements,
    this.createStockMovement,
    this.deleteStockMovement,
  );

  StockMovementStatus status = StockMovementStatus.initial;
  String? errorMessage;
  String? submitError;
  List<StockMovement> movements = [];
  List<StockMovement> filteredMovements = [];
  bool isSubmitting = false;
  DateTime? startDate;
  DateTime? endDate;

  int? selectedStockItemId;
  StockMovementType? selectedType;
  StockMovementReason? selectedReason;

  Future<void> load({int? stockItemId, DateTime? start, DateTime? end}) async {
    if (stockItemId != null) selectedStockItemId = stockItemId;
    if (start != null || end != null) {
      startDate = start;
      endDate = end;
    }
    status = StockMovementStatus.loading;
    notifyListeners();
    try {
      final startStr = startDate != null
          ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
          : null;
      final endStr = endDate != null
          ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
          : null;

      movements = await getStockMovements.call(
        stockItemId: selectedStockItemId,
        startDate: startStr,
        endDate: endStr,
      );
      _applyFilters();
      status = StockMovementStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = StockMovementStatus.error;
    }
    notifyListeners();
  }

  void filterByDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    load(stockItemId: selectedStockItemId, start: startDate, end: endDate);
  }

  void filterByType(StockMovementType? type) {
    selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void filterByReason(StockMovementReason? reason) {
    selectedReason = reason;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    filteredMovements = movements.where((m) {
      final matchesType = selectedType == null || m.type == selectedType;
      final matchesReason =
          selectedReason == null || m.reason == selectedReason;
      return matchesType && matchesReason;
    }).toList();
  }

  Future<bool> addMovement(StockMovementDto dto) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();
    try {
      final newMovement = await createStockMovement.call(dto);
      movements.insert(0, newMovement);
      _applyFilters();
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      submitError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeMovement(int id) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();
    try {
      await deleteStockMovement.call(id);
      movements.removeWhere((m) => m.id == id);
      _applyFilters();
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      submitError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
