import 'package:flutter/foundation.dart';
import 'package:restauran_menu/features/stock/domain/usecases/delete_unit.dart';
import 'package:restauran_menu/features/stock/domain/usecases/update_unit.dart';

import '../../data/models/stock_unit_dto.dart';
import '../../domain/entities/unit.dart';
import '../../domain/usecases/create_unit.dart';
import '../../domain/usecases/get_units.dart';

enum UnitStatus { initial, loading, loaded, error }

class UnitProvider extends ChangeNotifier {
  final GetUnits getUnitsUsecase;
  final CreateUnit createUnitUsecase;
  final DeleteUnit deleteUnitUsecase;
  final UpdateUnit updateUnitUsecase;

  UnitProvider(
    this.getUnitsUsecase,
    this.createUnitUsecase,
    this.deleteUnitUsecase,
    this.updateUnitUsecase,
  );

  UnitStatus status = UnitStatus.initial;
  String? errorMessage;
  List<Unit> units = [];
  bool isSubmitting = false;
  String? submitError;

  Future<void> load() async {
    status = UnitStatus.loading;
    notifyListeners();
    try {
      units = await getUnitsUsecase.call();
      status = UnitStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = UnitStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addUnit(StockUnitDto dto) async => await _runSubmit(() async {
    final unit = await createUnitUsecase.call(dto);
    units.add(unit);
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

  // Delete Unit
  Future<bool> removeUnit(int id) async => await _runSubmit(() async {
    await deleteUnitUsecase.call(id);
    units.removeWhere((u) => u.id == id);
  });

  // Update Unit
  Future<bool> updateUnit(int id, StockUnitDto dto) async =>
      await _runSubmit(() async {
        final upd = await updateUnitUsecase.call(id, dto);
        final idx = units.indexWhere((u) => u.id == id);
        if (idx != -1) units[idx] = upd;
      });

  Unit? getUnitById(int id) {
    final unit = units.firstWhere(
      (u) => u.id == id,
      orElse: () => Unit(id: 0, name: '-'),
    );
    return unit;
  }
}
