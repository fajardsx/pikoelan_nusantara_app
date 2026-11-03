import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache_lts/dio_http_cache_lts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logarte/logarte.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:restauran_menu/core/network/cache/cache_interceptor.dart';
import 'package:restauran_menu/core/network/cache/cache_manager.dart';
import 'package:restauran_menu/core/network/envi_services.dart';
import 'package:restauran_menu/core/services/shared_pref_services.dart';

import '../../main.dart';
import '../services/app_log.dart';
import 'app_services_helper.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  DioClient._internal();
  Dio? _dio;
  final storage = const FlutterSecureStorage();

  static DioClient get instance => _instance;

  /// Apakah [init] sudah pernah jalan. Dipakai untuk guard agar tidak
  /// lempar `LateInitializationError: dio has not been initialized`.
  bool get isInitialized => _dio != null;

  /// Akses aman: otomatis panggil [init] kalau belum di-init.
  /// [init] butuh [EnviServices.baseUrl] & [SharedPrefServices.pref]
  /// sudah siap — pastikan urutan di `main()` benar.
  Dio get dio {
    ensureInitialized();
    return _dio!;
  }

  /// Idempotent: aman dipanggil berulang. Kalau sudah init dan baseUrl
  /// berubah (mis. ganti flavor), cukup update options tanpa reset
  /// interceptor/token.
  void init({bool force = false}) {
    final base = (EnviServices.baseUrl ?? '').trim();
    if (base.isEmpty) {
      throw StateError(
        'BASE_URL kosong. Jalankan dengan '
        '--dart-define-from-file=config.dev.json (lihat .vscode/launch.json) '
        'atau pastikan EnviServices.init() dipanggil sebelum DioClient.init().',
      );
    }
    if (_dio != null && !force) {
      // Sinkronkan baseUrl kalau berubah tanpa rebuild interceptor.
      if (_dio!.options.baseUrl != base) {
        _dio!.options.baseUrl = base;
      }
      return;
    }
    final dioInstance = Dio(
      BaseOptions(
        baseUrl: base, // contoh API
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        headers: {'Content-Type': 'application/json;charset=utf-8'},
      ),
    );
    if (kDebugMode) {
      dioInstance.interceptors.add(
        PrettyDioLogger(
          request: true,
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          compact: false,
          maxWidth: 100,
          filter: (request, FilterArgs filter) {
            if (filter.isResponse &&
                (filter.data is Map<String, dynamic>) &&
                jsonEncode(filter.data).length > 3000) {
              AppLog.instance.logInfo(
                'Response data too long, truncated for logging.',
              );
              return false;
            }
            return true;
          },
        ),
      );
    }
    dioInstance.interceptors.add(LogarteDioInterceptor(logService.logarte));
    dioInstance.interceptors.add(
      CacheInterceptor(CacheManager(SharedPrefServices.pref)),
    );
    _dio = dioInstance;
  }

  /// Pastikan dio siap. Dipanggil otomatis oleh getter [dio] dan semua
  /// method request (get/post/put/delete/upload/download) supaya tidak ada
  /// lagi `LateInitializationError: dio has not been initialized`.
  void ensureInitialized() {
    if (_dio == null) init();
  }

  void saveToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  void cleanToken() {
    dio.options.headers.remove("Authorization");
  }

  Future<Response> get(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    try {
      // final connectivityService = sl.get<ConnectivityService>(
      //   instanceName: Consts.connectivityServiceTag,
      // );
      // final isConnected = await connectivityService.hasConnection();
      // if (!isConnected) {
      //   forceRefresh = false;
      // }

      return await dio.get(
        url,
        queryParameters: queryParameters,
        //options: cacheOpts,
        options: Options(extra: {'no-cache': forceRefresh}),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      await checkStatuscode(
        e.response?.statusCode,
        response: data is Map ? data : null,
      );
      rethrow;
    }
  }

  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    try {
      return await dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: buildCacheOptions(
          const Duration(minutes: 1), // cache selama 1 menit
          forceRefresh: forceRefresh, // kalau true, selalu fetch ulang
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      await checkStatuscode(
        e.response?.statusCode,
        response: data is Map ? data : null,
      );
      rethrow;
    }
  }

  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    try {
      return await dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: buildCacheOptions(
          const Duration(minutes: 2), // cache selama 2 menit
          forceRefresh: forceRefresh, // kalau true, selalu fetch ulang
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      await checkStatuscode(
        e.response?.statusCode,
        response: data is Map ? data : null,
      );
      rethrow;
    }
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    try {
      return await dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: buildCacheOptions(
          const Duration(minutes: 2), // cache selama 5 menit
          forceRefresh: forceRefresh, // kalau true, selalu fetch ulang
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      await checkStatuscode(
        e.response?.statusCode,
        response: data is Map ? data : null,
      );
      rethrow;
    }
  }

  Future<Response> uploadFile(
    String url, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    try {
      return await dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (_) {
      // checkStatuscode(e.response?.statusCode, response: e.response!.data);
      rethrow;
    }
  }

  Future<ResponseBody> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      await checkStatuscode(
        e.response?.statusCode,
        response: data is Map ? data : null,
      );
      rethrow;
    }
  }

  Future<Response> patch(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
  }) async {
    try {
      return await dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: buildCacheOptions(
          const Duration(minutes: 2), // cache duration for PATCH requests
          forceRefresh: forceRefresh,
        ),
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      await checkStatuscode(
        e.response?.statusCode,
        response: responseData is Map ? responseData : null,
      );
      rethrow;
    }
  }

  // Example method to get Dio instance
  Dio get client => dio;

  // bool _isMapContainUint8List(Map<String, dynamic> map) {
  //   for (var value in map.values) {
  //     if (value is Uint8List) {
  //       return true;
  //     } else if (value is Map<String, dynamic>) {
  //       if (_isMapContainUint8List(value)) {
  //         return true;
  //       }
  //     }
  //   }
  //   return false;
  // }
}
