import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/main.dart';
import 'package:restauran_menu/routes/navigator.dart';

/// Dipanggil dari [DioClient] setiap request gagal.
/// 401 (termasuk body `{"code":401,"message":"No token provided"}`)
/// berarti token hilang / kedaluwarsa -> bersihkan sesi dan kembali ke login.
///
/// Navigasi pakai pop-until-first (bukan push route login) supaya
/// `_StartupGate` di main.dart tetap jadi route pertama dan otomatis
/// menampilkan LoginScreen saat status `loggedOut` — sekaligus bisa
/// berbalik ke RoleSelection saat user login ulang. Kalau pakai
/// pushNamedAndRemove(login), gate terbuang dan user nyangkut di
/// LoginScreen walau status sudah `loggedIn`.
///
/// Guard [_handling401] mencegah badai logout saat beberapa request
/// gagal bersamaan.
bool _handling401 = false;

Future<void> checkStatuscode(
  int? statuscode, {
  Map? response,
  String? title,
}) async {
  if (statuscode != 200 && statuscode != 422) {
    if (statuscode == 401) {
      if (_handling401) return;
      _handling401 = true;
      try {
        try {
          await sl<AuthProvider>().logOut();
        } catch (_) {
          // logout lokal tidak boleh menggagalkan navigasi ke login
        }
        // Kembali ke _StartupGate — gate otomatis tukar ke LoginScreen.
        try {
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
        } catch (_) {
          // abaikan — gate sudah menampilkan login lewat status loggedOut
        }
        try {
          NavigationService.showSnackBar(
            'Sesi berakhir, silakan login kembali',
            isError: true,
          );
        } catch (_) {
          // abaikan — mis. belum ada Scaffold saat transisi ke login
        }
      } finally {
        // beri jeda supaya request susulan tidak memicu snackbar ganda,
        // tapi reset lagi agar login ulang tetap bisa auto-logout berikutnya.
        Future.delayed(const Duration(seconds: 2), () {
          _handling401 = false;
        });
      }
    } else {
      NavigationService.showSnackBar(
        response != null
            ? (response["errors"] != null
                  ? getErrorMessage(response["errors"])
                  : response["message"] ?? "Request Failed")
            : "Request Failed",
        isError: true,
      );
      // AlertManager.show(
      //   title: title ?? "Failed",
      //   desc: response != null
      //       ? (response["errors"] != null
      //           ? getErrorMessage(response["errors"])
      //           : response["message"] ?? "Request Failed")
      //       : "Request Failed",
      //   types: 2,
      //   forceClose: true,
      // );
    }
  }
}
