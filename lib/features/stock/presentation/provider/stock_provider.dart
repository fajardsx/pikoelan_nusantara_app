import 'package:flutter/foundation.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/usecases/get_stock_items.dart';
import '../../domain/usecases/create_stock_item.dart';
import '../../domain/usecases/update_stock_item.dart';
import '../../domain/usecases/delete_stock_item.dart';
import '../../data/models/stock_item_dto.dart';

enum StockStatus { initial, loading, loaded, error }

class StockProvider extends ChangeNotifier {
  final GetStockItems getStockItems;
  final CreateStockItem createStockItem;
  final UpdateStockItem updateStockItem;
  final DeleteStockItem deleteStockItem;

  StockProvider(this.getStockItems, this.createStockItem, this.updateStockItem, this.deleteStockItem);

  StockStatus status = StockStatus.initial;
  String? errorMessage;
  List<StockItem> items = [];
  bool isSubmitting = false;
  String? submitError;

  Future<void> load() async {
    status = StockStatus.loading;
    notifyListeners();
    try {
      items = await getStockItems.call();
      status = StockStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = StockStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addItem(StockItemDto dto) async => await _runSubmit(() async {
    final item = await createStockItem.call(dto);
    items.add(item);
  });

  Future<bool> editItem(int id, StockItemDto dto) async => await _runSubmit(() async {
    final updated = await updateStockItem.call(id, dto);
    final index = items.indexWhere((i) => i.id == id);
    if (index >= 0) items[index] = updated;
  });

  Future<bool> removeItem(int id) async => await _runSubmit(() async {
    await deleteStockItem.call(id);
    items.removeWhere((i) => i.id == id);
  });

  Future<bool> _runSubmit(Future<void> Function() action) async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();
    try {
      await action();
      isSubmitting = false;
      return true;
    } catch (e) {
      isSubmitting = false;
      submitError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }
}
