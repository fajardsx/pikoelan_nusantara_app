import 'dart:convert';

import 'package:restauran_menu/core/network/cache/cache_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  final SharedPreferences _prefs;
  static const String _cachePrefix = "cache_";

  CacheManager(this._prefs);

  Future<T?> get<T>(String key) async {
    final cacheKey = _getCacheKey(key);
    final data = _prefs.getString(cacheKey);

    if (data == null) return null;

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final cacheEntry = CacheEntry.fromJson(json);

      if (cacheEntry.isExpired) {
        await remove(key);
        return null;
      }

      return cacheEntry.data as T;
    } catch (e) {
      await remove(key);
      return null;
    }
  }

  Future<void> set<T>(String key, T data, Duration expiration) async {
    final cachekey = _getCacheKey(key);
    final expiredDate = DateTime.now().add(expiration);
    final cacheEntry = CacheEntry(data: data, expiredDate: expiredDate);
    await _prefs.setString(cachekey, jsonEncode(cacheEntry.toJson()));
  }

  Future<void> remove(String key) async {
    final cacheKey = _getCacheKey(key);
    await _prefs.remove(cacheKey);
  }

  Future<void> clean() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  String _getCacheKey(String key) => '$_cachePrefix$key';
}
