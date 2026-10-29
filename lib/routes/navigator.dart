// lib/core/navigation/navigation_service.dart
import 'package:flutter/material.dart';

import '../main.dart';

class NavigationService {
  // Navigate to new screen
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // Navigate and remove previous
  static Future<dynamic> navigateAndRemove(String routeName) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  // Navigate and replace
  static Future<dynamic> navigateAndReplace(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  // Go back
  static void goBack([dynamic result]) {
    return navigatorKey.currentState!.pop(result);
  }

  // Show dialog
  static Future<T?> showDialogGlobal<T>(Widget dialog) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      builder: (_) => dialog,
    );
  }

  // Show snackbar
  static void showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackBar);
  }
}
