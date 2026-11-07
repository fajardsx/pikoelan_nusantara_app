import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_units.dart';
import '../../domain/usecases/create_unit.dart';
import '../../data/models/stock_unit_dto.dart';
import '../../domain/entities/unit.dart';

enum UnitStatus { initial, loading, loaded, error }

class UnitProvider extends ChangeNotifier {
  final GetUnits getUnits;
  final CreateUnit createUnit;

  UnitProvider(this.getUnits, this.createUnit);

  UnitStatus status = UnitStatus.initial;
  String? errorMessage;
  List<Unit> units = [];
  bool isSubmitting = false;
  String? submitError;

  Future<void> load() async {
    status = UnitStatus.loading;
    notifyListeners();
    try {
      units = await getUnits.call();
      status = UnitStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = UnitStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addUnit(StockUnitDto dto) async => await _runSubmit(() async {
    final unit = await createUnit.call(dto);
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
}
