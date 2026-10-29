import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/app_colors.dart';
import 'package:restauran_menu/routes/name_route.dart';
import 'package:restauran_menu/routes/navigator.dart';

import '../../../../flavors.dart';
import '../../../../main.dart';

bool _isLogarteAttached = false;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  initState() {
    super.initState();
    _enableDebug();
    _checkUserSession();
  }

  void _checkUserSession() async {
    //BlocProvider.of<AuthCubit>(context).init();
    //final User? user = await sl<AuthCubit>().checkLogin();
    // if (user != null) {
    unawaited(NavigationService.navigateAndRemove(NameRoute.home));
    // } else {
    //   unawaited(NavigationService.navigateAndRemove(NameRoute.login));
    // }
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
    return Scaffold(
      body: Container(
        color: appColors.primary,
        alignment: Alignment.center,
        child: const SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Orders Apps'),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
