import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:restauran_menu/features/customers/data/models/category_hive.dart';
import '../../features/customers/data/models/menu_item_hive.dart';
import '../../features/kasir/data/models/order_hive.dart';
import '../../features/kasir/data/models/order_item_hive.dart';
import '../../features/waiters/data/models/table_hive.dart';

/// Opens the shared Hive boxes used as the local database for Menu, Orders
/// and Tables across the Customer / Kasir / Kitchen / Waiter modules.
///
/// `Hive.initFlutter()` picks the right storage automatically per platform
/// (IndexedDB on web, app documents directory on Android/iOS/desktop), so
/// unlike Isar there's no manual directory/engine branching needed here.
class HiveService {
  HiveService._();

  static const categoryBoxName = 'categories';
  static const menuBoxName = 'menu_items';
  static const orderBoxName = 'orders';
  static const tableBoxName = 'tables';

  static Box<CategoryHive>? _categoryBox;
  static Box<MenuItemHive>? _menuBox;
  static Box<OrderHive>? _orderBox;
  static Box<TableHive>? _tableBox;

  static Future<void> open() async {
    if (_menuBox != null) return;

    await Hive.initFlutter();

    Hive.registerAdapter(CategoryHiveAdapter());
    Hive.registerAdapter(MenuItemHiveAdapter());
    Hive.registerAdapter(OrderItemHiveAdapter());
    Hive.registerAdapter(OrderHiveAdapter());
    Hive.registerAdapter(TableHiveAdapter());

    _categoryBox = await Hive.openBox<CategoryHive>(categoryBoxName);
    _menuBox = await Hive.openBox<MenuItemHive>(menuBoxName);
    _orderBox = await Hive.openBox<OrderHive>(orderBoxName);
    _tableBox = await Hive.openBox<TableHive>(tableBoxName);
  }

  static Box<CategoryHive> get categoryBox {
    final box = _categoryBox;
    if (box == null) {
      throw StateError('HiveService.open() must be awaited before use.');
    }
    return box;
  }

  static Box<MenuItemHive> get menuBox {
    final box = _menuBox;
    if (box == null) {
      throw StateError('HiveService.open() must be awaited before use.');
    }
    return box;
  }

  static Box<OrderHive> get orderBox {
    final box = _orderBox;
    if (box == null) {
      throw StateError('HiveService.open() must be awaited before use.');
    }
    return box;
  }

  static Box<TableHive> get tableBox {
    final box = _tableBox;
    if (box == null) {
      throw StateError('HiveService.open() must be awaited before use.');
    }
    return box;
  }
}
