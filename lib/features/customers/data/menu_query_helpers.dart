import 'package:restauran_menu/features/menu/domain/entities/menu_item_entity.dart';

/// Client-side filtering helpers for a menu list sourced from
/// [MenuRepository.watchAll]. Mirrors the old `DummyMenuData` static API so
/// call sites barely change when switching from static dummy data to a live
/// Hive stream.
extension MenuItemListQuery on List<MenuItemEntity> {
  List<MenuItemEntity> get favorites =>
      where((item) => item.isFavorite).toList();

  List<MenuItemEntity> get bannerItems =>
      where((item) => item.isBanner).toList();

  List<MenuItemEntity> byCategory(int? categoryId) {
    if (categoryId == null) return this;
    return where((item) => item.categoryId == categoryId).toList();
  }

  List<MenuItemEntity> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return this;
    return where((item) => item.name.toLowerCase().contains(q)).toList();
  }
}
