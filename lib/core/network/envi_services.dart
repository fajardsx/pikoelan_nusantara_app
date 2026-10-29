import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/core/common/common_utils.dart';

class EnviServices {
  static final EnviServices _instance = EnviServices._internal();
  static String? baseUrl = "";
  static String? defaultUrl = "";
  factory EnviServices() {
    return _instance;
  }
  EnviServices._internal();

  static Future<void> init() async {
    // Dibaca dari --dart-define-from-file (lihat config.dev.json /
    // config.prod.json + .vscode/launch.json). Kalau developer lupa pakai
    // flag tsb, String.fromEnvironment = "".
    // PENTING (Web release): jangan fallback ke localhost karena itu yang
    // bikin API + gambar gagal dimuat setelah `flutter build web --release`
    // tanpa --dart-define-from-file. Fallback ke URL produksi.
    const defined = String.fromEnvironment('BASE_URL');
    const slugDefined = String.fromEnvironment('BASE_SLUG');
    const titleDefined = String.fromEnvironment('BASE_TITLE');
    Consts.appVersion = await getVersion();
    if (defined.trim().isNotEmpty) {
      baseUrl = defined.trim();
      Consts.appName = titleDefined.trim();
      Consts.appSlug = slugDefined.trim();
    } else {
      // Samakan dengan config.prod.json agar build release tetap jalan
      // walau lupa pakai --dart-define-from-file.
      //baseUrl = "https://menu-maju-backend.onrender.com/";
    }
  }
}
