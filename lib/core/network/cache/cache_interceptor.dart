import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:restauran_menu/core/network/cache/cache_manager.dart';

class CacheInterceptor extends Interceptor {
  final CacheManager _cacheManager;
  final Duration _defaultCacheDuration;

  CacheInterceptor(
    this._cacheManager, {
    Duration defaultCacheDuration = const Duration(minutes: 30),
  }) : _defaultCacheDuration = defaultCacheDuration;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.method != "GET" || options.extra['no-cache'] == true) {
      return handler.next(options);
    }

    final cacheKey = _getKeyCache(options);
    final cacheData = await _cacheManager.get<Map<String, dynamic>>(cacheKey);

    if (cacheData != null) {
      final Map<String, List<String>> headers = _convertMap(
        cacheData['headers'],
      );

      final response = Response(
        requestOptions: options,
        data: cacheData['data'],
        statusCode: cacheData['statusCode'],
        headers: Headers.fromMap(headers),
        extra: {'cache': true},
      );

      return handler.resolve(response);
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.method != 'GET' ||
        response.requestOptions.extra['no-cache'] == true) {
      return handler.next(response);
    }

    final cacheKey = _getKeyCache(response.requestOptions);
    final cacheDuration =
        response.requestOptions.extra['cache-duration'] as Duration? ??
        _defaultCacheDuration;

    final cacheData = {
      'data': response.data,
      'statusCode': response.statusCode,
      'headers': response.headers.map,
    };

    await _cacheManager.set(cacheKey, cacheData, cacheDuration);
    return handler.next(response);
  }

  String _getKeyCache(RequestOptions options) {
    final uri = options.uri.toString();
    final params = options.queryParameters.isNotEmpty
        ? jsonEncode(options.queryParameters)
        : "";
    return "$uri|$params";
  }

  Map<String, List<String>> _convertMap(Map<String, dynamic> cacheData) {
    return cacheData.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      } else {
        return MapEntry(key, [value?.toString() ?? '']);
      }
    });
  }
}
