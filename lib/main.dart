import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restauran_menu/core/common/common_constant.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/core/network/dio_client.dart';
import 'package:restauran_menu/core/network/envi_services.dart';
import 'package:restauran_menu/core/network/logarte_services.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';
import 'package:restauran_menu/core/themes/app_theme.dart';
import 'package:restauran_menu/features/auth/presentation/pages/auth_page.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/customers/presentation/provider/cart_provider.dart';
import 'package:restauran_menu/features/customers/presentation/provider/public_menu_provider.dart';
import 'package:restauran_menu/flavors.dart';
import 'package:restauran_menu/routes/app_route.dart';

const bool isProduction = bool.fromEnvironment('dart.vm.product');
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final logService = LogarteServices();

const _flavorMap = {
  'development': Flavor.development,
  'production': Flavor.production,
};
void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // Fix bottom nav tertutup soft navigation Android (edge-to-edge / gesture & 3-button)
      // Aktifkan edge-to-edge dan buat navigation bar transparan agar viewPadding.bottom akurat
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      if (!kIsWeb) {
        F.appFlavor = _flavorMap[appFlavor] ?? Flavor.development;
      }
      await EnviServices.init();
      await SharedPrefServices.init();
      await initDependencies();
      sl<DioClient>();
      await sl.allReady();

      runApp(const MyApp());
    },
    (error, stackTrace) {
      debugPrint('Caught error: $error');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => sl<AuthProvider>()..init(),
            ),
            // Cart lives above the Navigator so it survives pushNamed
            // navigation across the whole Self-Order flow.
            ChangeNotifierProvider(create: (context) => CartProvider(sl())),
            // Public menu (GET api/menu/:slug) juga global supaya
            // Beranda, Semua Menu, dan Pembayaran pakai slug/data sama.
            ChangeNotifierProvider(
              create: (context) => sl<PublicMenuProvider>(),
            ),
          ],
          child: MaterialApp(
            title: Consts.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: Builder(
              builder: (context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(Consts.textScaleValue),
                  ),
                  child:
                      const AuthPage(), //const StartupGate(), // const RoleSelectionScreen(),
                );
              },
            ),
            navigatorKey: navigatorKey,
            routes: AppRoute().routes,
            navigatorObservers: [routeObserver],
            // onGenerateRoute: (settings) {
            //   if (settings.name != null) {
            //     final Uri uri = Uri.parse(settings.name!);
            //     final String path = uri.path;

            //     if (path == NameRoute.customerHome) {
            //       final String? slug = uri.queryParameters['slug'];
            //       return MaterialPageRoute(
            //         builder: (context) => CustomerHomeScreen(slug: slug),
            //         settings: settings,
            //       );
            //     }
            //   }
            //   return null;
            // },
            //initialRoute: NameRoute.rootView,
          ),
        );
      },
    );
  }
}
