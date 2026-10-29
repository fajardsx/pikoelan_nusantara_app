import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:restauran_menu/features/auth/domain/entities/user_hive.dart';

class HiveServices {
  static final HiveServices _instance = HiveServices._internal();
  factory HiveServices() => _instance;
  HiveServices._internal();

  static bool _isInitialized = false;

  /// Initialize Hive with proper path settings
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive with document directory
    //final documentDir = await getApplicationDocumentsDirectory();
    //await Hive.initFlutter(documentDir.path);
    await Hive.initFlutter();

    // Register adapters here if you have any
    Hive.registerAdapter(UserHiveAdapter());

    _isInitialized = true;
  }

  /// Open a box with the given name
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!_isInitialized) {
      await init();
    }

    if (!Hive.isBoxOpen(boxName)) {
      return Hive.openBox<T>(boxName);
    }

    return Hive.box<T>(boxName);
  }

  /// Get a box (must be opened first)
  Box<T> getBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open. Call openBox first.');
    }
    return Hive.box<T>(boxName);
  }

  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// Close all boxes
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Clear all data from a box
  Future<void> clearBox(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  /// Delete a box completely
  Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }

  /// Check if a box exists
  Future<bool> isBoxExists(String boxName) {
    return Hive.boxExists(boxName);
  }

  /// Get count of items in a box
  int getBoxLength(String boxName) {
    final box = getBox(boxName);
    return box.length;
  }
}
