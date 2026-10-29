import 'package:flutter/material.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/main.dart';

import 'package:restauran_menu/core/themes/restaurant_colors.dart';

/// Helper terpusat untuk logout manual (tombol Keluar) maupun otomatis (401).
///
/// Alur: konfirmasi dialog -> [AuthProvider.logOut] (hapus token + user
/// di SharedPreferences + header Dio) -> kembali ke screen pertama
/// (`_StartupGate` di main.dart) yang otomatis menampilkan LoginScreen
/// saat status `loggedOut`. Pakai pop-until-first (bukan push login route)
/// supaya setelah login ulang gate bisa berbalik ke RoleSelection.
/// Tanpa langkah ini token basi tetap tersimpan sehingga request berikutnya
/// terus gagal dengan `{"code":401,"message":"No token provided"}`.
Future<void> confirmAndLogout(
  BuildContext context, {
  String title = 'Keluar dan logout?',
  String message =
      'Sesi login akan dihapus dan kamu kembali ke halaman login.',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            'Logout',
            style: TextStyle(color: RestaurantColors.danger),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await sl<AuthProvider>().logOut();
  // Kembali ke _StartupGate (route pertama). Gate membaca AuthStatus dan
  // menampilkan LoginScreen secara otomatis.
  try {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  } catch (_) {
    // abaikan — gate sudah menampilkan login lewat status loggedOut
  }
}
