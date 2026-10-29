import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefServices {
  static SharedPrefServices? _instance;

  SharedPrefServices._();
  // Jangan `late final` supaya init() idempotent (dipanggil 2x tidak
  // lempar LateInitializationError saat hot-restart / test).
  static SharedPreferences? _prefs;

  static SharedPreferences get pref {
    final p = _prefs;
    if (_instance == null || p == null) {
      throw Exception("SharedPrefServices is not Initialized.");
    }
    return p;
  }

  static Future<void> init() async {
    if (_instance != null && _prefs != null) return;
    _instance = SharedPrefServices._();
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
