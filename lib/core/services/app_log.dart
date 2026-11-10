// import 'dart:async';

import 'package:dio/dio.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:restauran_menu/core/helper/snackbar_helper.dart';

class AppLog {
  final Logger _logger = Logger();
  AppLog._internal();

  static final AppLog _instance = AppLog._internal();
  static AppLog get instance => _instance;

  void logInfo(String message, {bool popShow = true}) {
    _logger.i(message);
    //LogarteServices().logarte.log(message);
    if (popShow) SnackbarHelper.showInfo(message);
  }

  void logWarning(String message, {bool popShow = true}) {
    _logger.w(message);
    //LogarteServices().logarte.log(message);
    if (popShow) SnackbarHelper.showWarning(message);
  }

  void logError(String message, Object e, StackTrace s, {bool popShow = true}) {
    late final String endpoint;
    late final String request;
    late final String requestHeader;
    late final String response;
    if (e is DioException) {
      if (e.requestOptions.data is Map) {
        final containPassword = (e.requestOptions.data as Map).containsKey(
          'password',
        );
        final data = Map.of(e.requestOptions.data);
        if (containPassword) {
          data['password'] = '******';
        }
        request = data.toString();
      } else {
        request = e.requestOptions.data.toString();
      }
      endpoint = e.requestOptions.uri.toString();
      requestHeader = e.requestOptions.headers.toString();
      response = e.response?.data.toString() ?? '';
    } else {
      endpoint = '';
      request = '';
      requestHeader = '';
      response = '';
    }
    final Map<String, dynamic> info = {
      'endpoint': endpoint,
      'request.payload': request,
      'request.headers': requestHeader,
      'response.payload': response,
    };

    // unawaited(
    //   FirebaseCrashlytics.instance.recordError(
    //     e,
    //     s,
    //     fatal: true,
    //     information: [info],
    //   ),
    // );
    _logger.e(message, error: e, stackTrace: s);
    if (popShow) SnackbarHelper.showError(message);
  }
}
