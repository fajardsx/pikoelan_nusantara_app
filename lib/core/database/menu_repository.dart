import 'package:hive_ce/hive_ce.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';

import '../../features/customers/data/models/menu_item_hive.dart';

/// Single source of truth for menu data, backed by Hive. Used by Customer
/// Self-Order (browse/search), Waiter (take-order), and Kasir's "Kelola
/// Menu" (create/update/delete).
class MenuRepository {
  MenuRepository(this._box);
  final Box<MenuItemHive> _box;

  List<MenuItemEntity> _readAll({int? categoryId}) {
    var entities = _box.values.map((h) => h.toEntity()).toList();
    if (categoryId != null) {
      entities = entities.where((e) => e.categoryId == categoryId).toList();
    }
    entities.sort((a, b) => a.name.compareTo(b.name));
    return entities;
  }

  /// Live list of every menu item, sorted by name. Emits immediately with
  /// the current data, then again on every write. Optionally filtered by [categoryId].
  Stream<List<MenuItemEntity>> watchAll({int? categoryId}) async* {
    yield _readAll(categoryId: categoryId);
    await for (final _ in _box.watch()) {
      yield _readAll(categoryId: categoryId);
    }
  }

  Future<void> addItem(MenuItemEntity item) async {
    // Key Hive == item.id (bukan auto-increment `_box.add()`).
    // Dedup by id ATAU nama (nama unik secara tampilan).
    final normalized = item.name.toLowerCase().trim();
    Object? matchKey;
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v == null) continue;
      if ((item.id != -1 && v.id == item.id) ||
          v.name.toLowerCase().trim() == normalized) {
        matchKey = key;
        break;
      }
    }

    // Tentukan key yang dipakai: item.id kalau valid (!= -1),
    // kalau item baru lokal (-1) pakai key lama bila ada, else id baru.
    int keyToUse;
    if (item.id != -1) {
      keyToUse = item.id;
    } else if (matchKey is int) {
      keyToUse = matchKey;
    } else {
      keyToUse = _nextId();
    }

    // Hapus key lama bila beda (misal data lokal ditimpa ID dari API).
    if (matchKey != null && matchKey != keyToUse) {
      await _box.delete(matchKey);
    }

    await _box.put(keyToUse, MenuItemHive.fromEntity(item, id: keyToUse));
  }

  /// [item.id] must be an existing Hive key (i.e. an item read back from
  /// [watchAll]/[addItem], not a hand-built one).
  Future<void> updateItem(MenuItemEntity item) async {
    final id = int.tryParse(item.id.toString());
    if (id == null) return;
    await _box.put(id, MenuItemHive.fromEntity(item, id: id));
  }

  Future<void> deleteItem(MenuItemEntity item) async {
    final id = int.tryParse(item.id.toString());
    if (id == null) return;
    await _box.delete(id);
  }

  Future<void> addAll(List<MenuItemEntity> items) async {
    for (final item in items) {
      await addItem(item);
    }
  }

  Future<void> reset() async {
    await _box.clear(); // hapus semua entri
  }

  /// Populates the box with [seedItems] the very first time the app runs
  /// (no-op if the box already has data).
  ///
  /// Key Hive == `item.id` lewat `put`, tanpa `add()` supaya tidak
  /// kena auto-increment Hive.
  Future<void> seedIfEmpty(List<MenuItemEntity> seedItems) async {
    if (_box.isNotEmpty) return;
    for (final item in seedItems) {
      final id = item.id != -1 ? item.id : _nextId();
      await _box.put(id, MenuItemHive.fromEntity(item, id: id));
    }
  }

  /// Hitung id lokal berikutnya (max key/id + 1) supaya `put(id, ...)`
  /// tetap unik tanpa memakai auto-increment `_box.add()`.
  int _nextId() {
    var max = 0;
    for (final key in _box.keys) {
      if (key is int && key > max) max = key;
      final value = _box.get(key);
      if (value != null && value.id > max) max = value.id;
    }
    return max + 1;
  }
}
