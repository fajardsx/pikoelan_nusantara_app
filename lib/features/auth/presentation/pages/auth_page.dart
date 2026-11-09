import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/flavors.dart';
import 'package:restauran_menu/main.dart';
import 'package:restauran_menu/startup_gate.dart';

bool _isLogarteAttached = false;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String? webSlug;

  @override
  void initState() {
    super.initState();
    // Aman di Web & Mobile: Uri.base hanya valid di Web untuk query ?slug=.
    // Di Android/iOS kIsWeb=false -> webSlug tetap null -> tampilkan Login.
    // Jangan pakai package:web di sini karena crash di Mobile
    // dan `webSlug!` crash saat null.

    try {
      webSlug = Uri.base.queryParameters['slug'];
      //debugPrint("slug : $webSlug");
      webSlug ??= Consts.appSlug;
    } catch (_) {
      webSlug = "";
    }
    if (!kIsWeb) {
      _enableDebug();
    }
  }

  void _enableDebug() {
    // In App Debug
    if (!_isLogarteAttached) {
      logService.logarte.attach(
        context: context,
        visible: (F.appFlavor == Flavor.production) ? false : true,
      );
      _isLogarteAttached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (kIsWeb) {
    //   final slug = (webSlug ?? '').trim();
    //   if (slug.isNotEmpty) return CustomerHomeScreen(slug: slug);
    // }
    return const StartupGate();
  }
}
