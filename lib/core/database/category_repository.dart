import 'package:hive_ce/hive_ce.dart';
import 'package:restauran_menu/features/menu/domain/entities/menu_category_entity.dart';

import '../../features/customers/data/models/category_hive.dart';

class CategoryRepository {
  CategoryRepository(this._box);
  final Box<CategoryHive> _box;

  List<MenuCategoryEntity> _readAll() {
    final entities = _box.values.map((h) => h.toEntity()).toList();
    entities.sort((a, b) => a.name.compareTo(b.name));
    return entities;
  }

  Stream<List<MenuCategoryEntity>> watchAll() async* {
    yield _readAll();
    await for (final _ in _box.watch()) {
      yield _readAll();
    }
  }

  Future<void> saveCategory(MenuCategoryEntity category) async {
    // Key Hive == category.id (bukan auto-increment `_box.add()`).
    // Dedup by id ATAU nama (nama unik secara tampilan).
    final normalized = category.name.toLowerCase().trim();
    Object? matchKey;
    for (final key in _box.keys) {
      final v = _box.get(key);
      if (v == null) continue;
      if ((category.id != -1 && v.id == category.id) ||
          v.name!.toLowerCase().trim() == normalized) {
        matchKey = key;
        break;
      }
    }
    //debugPrint("box cat id ${category.id} is exist ${matchKey != null}");

    // Tentukan key yang dipakai: category.id kalau valid (!= -1),
    // kalau kategori baru lokal (-1) pakai key lama bila ada, else id baru.
    int keyToUse;
    if (category.id != -1) {
      keyToUse = category.id;
    } else if (matchKey is int) {
      keyToUse = matchKey;
    } else {
      keyToUse = _nextId();
    }

    // Hapus key lama jika ID berbeda (misalnya data lokal ditimpa ID dari API)
    if (matchKey != null && matchKey != keyToUse) {
      await _box.delete(matchKey);
    }

    await _box.put(keyToUse, CategoryHive.fromEntity(category, id: keyToUse));
  }

  Future<int> addCategory(MenuCategoryEntity category) async {
    final exists = _box.values.any(
      (e) => e.name == category.name || e.id == category.id,
    );
    if (exists) {
      throw Exception('Kategori dengan nama "${category.name}" sudah ada.');
    } else {
      // Key Hive == category.id (bukan auto-increment `_box.add()`).
      final id = category.id != -1 ? category.id : _nextId();
      await _box.put(id, CategoryHive.fromEntity(category, id: id));
      return id;
    }
  }

  Future<void> updateCategory(MenuCategoryEntity category) async {
    //debugPrint("box cat id ${category.id}");
    await _box.put(
      category.id,
      CategoryHive.fromEntity(category, id: category.id),
    );
  }

  Future<void> deleteCategory(int id) async {
    await _box.delete(id);
  }

  Future<void> addAll(List<MenuCategoryEntity> categorys) async {
    for (final cat in categorys) {
      await saveCategory(cat);
    }
  }

  Future<void> reset() async {
    await _box.clear(); // hapus semua entri
  }

  Future<List<MenuCategoryEntity>> seedIfEmpty(List<String> names) async {
    if (_box.isNotEmpty) return _readAll();
    final created = <MenuCategoryEntity>[];
    for (final name in names) {
      // Key Hive == id lewat sekali `put`, tanpa `add()`
      // supaya tidak kena auto-increment Hive.
      final id = _nextId();
      final draft = CategoryHive(
        id: id,
        name: name,
        icon: null,
        sortOrder: 0,
        isActive: true,
      );
      await _box.put(id, draft);
      created.add(draft.toEntity());
    }
    return created;
  }

  /// Hitung id lokal berikutnya (max key/id + 1) supaya `put(id, ...)`
  /// tetap unik tanpa memakai auto-increment `_box.add()`.
  int _nextId() {
    var max = 0;
    for (final key in _box.keys) {
      if (key is int && key > max) max = key;
      final value = _box.get(key);
      if (value != null && value.id! > max) max = value.id!;
    }
    return max + 1;
  }
}
