import 'package:hive_ce/hive_ce.dart';
import '../../features/waiters/data/models/table_hive.dart';
import '../../features/waiters/domain/entities/table.dart';

/// Single source of truth for the floor's table status, backed by Hive.
class TableRepository {
  TableRepository(this._box);
  final Box<TableHive> _box;

  List<RestaurantTable> _readAll() {
    final entities = _box.values.map((h) => h.toEntity()).toList();
    entities.sort((a, b) => a.number.compareTo(b.number));
    return entities;
  }

  Stream<List<RestaurantTable>> watchAll() async* {
    yield _readAll();
    await for (final _ in _box.watch()) {
      yield _readAll();
    }
  }

  Future<void> occupyTable(
    int number, {
    required String orderNumber,
    int? guestCount,
  }) {
    return _mutate(number, (t) {
      t.statusIndex = TableStatus.terisi.index;
      t.orderNumber = orderNumber;
      t.guestCount = guestCount;
    });
  }

  Future<void> clearTable(int number) {
    return _mutate(number, (t) {
      t.statusIndex = TableStatus.kosong.index;
      t.orderNumber = null;
      t.guestCount = null;
    });
  }

  Future<void> _mutate(
    int number,
    void Function(TableHive table) update,
  ) async {
    TableHive? match;
    dynamic matchKey;
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null && value.number == number) {
        match = value;
        matchKey = key;
        break;
      }
    }
    if (match == null) return;
    update(match);
    await _box.put(matchKey, match);
  }

  /// Creates tables numbered 1..[count] the first time the app runs
  /// (no-op if the box already has data).
  Future<void> seedIfEmpty(int count) async {
    if (_box.isNotEmpty) return;
    for (var i = 1; i <= count; i++) {
      final draft = TableHive(id: -1, number: i, statusIndex: TableStatus.kosong.index);
      final id = await _box.add(draft);
      draft.id = id;
      await _box.put(id, draft);
    }
  }
}
