import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/app_colors.dart';
import 'package:restauran_menu/core/themes/app_fonts.dart';
import 'package:restauran_menu/main.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SnackbarHelper {
  static void _showSnackbar({
    required String title,
    required String message,
    Color? textColor,
    Color? backgroundColor,
    BuildContext? context,
  }) {
    if (context == null && navigatorKey.currentContext != null) {
      final snackbar = SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: appFonts.semibold.ts.copyWith(
                color: textColor ?? appColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: appFonts.ts.copyWith(color: textColor ?? appColors.white),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: backgroundColor ?? appColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
      );
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackbar);
    } else if (context != null) {
      final snackbar = Material(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor ?? appColors.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: appFonts.semibold.ts.copyWith(
                  color: textColor ?? appColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: appFonts.ts.copyWith(
                  color: textColor ?? appColors.white,
                ),
              ),
            ],
          ),
        ),
      );
      showTopSnackBar(
        Overlay.of(context),
        snackbar,
        snackBarPosition: SnackBarPosition.bottom,
      );
    }
  }

  static void showError(
    String message, {
    String title = 'Error',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      textColor: appColors.white,
      backgroundColor: appColors.error,
      context: context,
    );
  }

  static void showSuccess(
    String message, {
    String title = 'Success',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      textColor: appColors.white,
      backgroundColor: appColors.success,
      context: context,
    );
  }

  static void showInfo(
    String message, {
    String title = 'Info',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      textColor: appColors.white,
      backgroundColor: appColors.info,
      context: context,
    );
  }

  static void showWarning(
    String message, {
    String title = 'Warning',
    BuildContext? context,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      textColor: appColors.white,
      backgroundColor: appColors.warning,
      context: context,
    );
  }
}
