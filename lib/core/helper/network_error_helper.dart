import 'package:dio/dio.dart';
import 'package:restauran_menu/core/helper/snackbar_helper.dart';
import 'package:restauran_menu/core/services/app_log.dart';

class NetworkErrorHelper {
  static void handleError({
    required Object error,
    required StackTrace stackTrace,
    required String method,
  }) {
    if (error is DioException) {
      final errorMessage =
          (error.response?.data as Map?)?['message'] ??
          'An error occurred in $method. Please try again later.';
      AppLog.instance.logError(errorMessage, error, stackTrace);
      SnackbarHelper.showError(errorMessage);
    } else {
      AppLog.instance.logError(
        'An unexpected error occurred in $method',
        error,
        stackTrace,
      );
      SnackbarHelper.showError(
        'An unexpected error occurred in $method. Please try again later.',
      );
    }
  }
}
