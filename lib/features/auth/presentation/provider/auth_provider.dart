import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_entity.dart';
import 'package:restauran_menu/features/admin/domain/usecases/get_my_tenant_usecase.dart';
import 'package:restauran_menu/features/auth/data/models/login_payload.dart';
import 'package:restauran_menu/features/auth/domain/entities/user_entities.dart';
import 'package:restauran_menu/features/auth/domain/usecases/auth_login_usecase.dart';
import 'package:restauran_menu/features/auth/domain/usecases/auth_logout_usecase.dart';
import 'package:restauran_menu/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:restauran_menu/features/auth/domain/usecases/get_profile_usecase.dart';

enum AuthStatus { initial, loading, loggedIn, loggedOut, error }

class AuthProvider extends ChangeNotifier {
  final CheckAuthUsecase checkAuthUsecase;
  final GetProfileUsecase getProfileUsecase;
  final GetMyTenantUsecase getMyTenantUsecase;
  final AuthLoginUsecase logincase;
  final AuthLogoutUsecase logoutcase;

  AuthProvider(
    this.getProfileUsecase,
    this.checkAuthUsecase,
    this.getMyTenantUsecase,
    this.logoutcase,
    this.logincase,
  );

  AuthStatus status = AuthStatus.initial;
  AuthStatus authStatus = AuthStatus.initial;
  User? user;
  TenantEntity? tenant;
  String? errorMessage;

  void _setError(String message) {
    status = AuthStatus.error;
    errorMessage = message;
    AppLog.instance.logInfo('error $status');
    notifyListeners();
  }

  void _setLoading() {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  /// Ambil pesan yang ramah untuk UI dari [DioException].
  /// Jangan pakai `e.toString()` karena isinya teknis
  /// (`DioException [bad response]: ...`) dan tidak cocok tampil di login.
  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      // Format validasi: {"errors": [...]/ {...}, "message": "..."}
      try {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          final parts = <String>[];
          for (final item in errors) {
            if (item is Map && item['message'] is String) {
              parts.add(item['message'] as String);
            } else if (item is String) {
              parts.add(item);
            }
          }
          if (parts.isNotEmpty) return parts.join(' ');
        } else if (errors is Map && errors.isNotEmpty) {
          final parts = <String>[];
          for (final value in errors.values) {
            if (value is List) {
              parts.add(value.join(' '));
            } else if (value is String) {
              parts.add(value);
            }
          }
          if (parts.isNotEmpty) return parts.join(' ').trim();
        }
      } catch (_) {
        // abaikan parsing errors, fallback ke message di bawah
      }
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa internet lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';
      case DioExceptionType.unknown:
        if (e.message != null && e.message!.contains('SocketException')) {
          return 'Tidak ada koneksi internet.';
        }
        return 'Terjadi kesalahan jaringan. Coba lagi.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401 || code == 422) {
          // pesan server sudah diambil di atas kalau ada, ini fallback
          return 'Email atau kata sandi salah.';
        }
        return 'Login gagal (${code ?? 'unknown'}). Coba lagi.';
      // ignore: unreachable_switch_default
      default:
        return 'Login gagal. Coba lagi.';
    }
  }

  void init() async {
    try {
      _setLoading();
      final result = await checkLoginSilently();
      user = result;
      authStatus = result == null ? AuthStatus.loggedOut : AuthStatus.loggedIn;
      status = result == null ? AuthStatus.loggedOut : AuthStatus.loggedIn;
      errorMessage = null;
      notifyListeners();
    } on DioException catch (e, s) {
      AppLog.instance.logError('Auth Login', e, s);
      _setError(_dioMessage(e));
    } catch (e, s) {
      AppLog.instance.logError('Auth Login', e, s);
      _setError(e.toString());
    }
  }

  /// Versi tanpa side-effect status/notify — dipakai oleh [init]
  /// supaya error dari [checkLogin] tidak di-overwrite jadi loggedOut.
  Future<User?> checkLoginSilently() async {
    final result = await checkAuthUsecase();
    AppLog.instance.logInfo("login ${result?.name}", popShow: false);
    return result;
  }

  Future<User?> checkLogin() async {
    try {
      _setLoading();
      final result = await checkAuthUsecase();
      AppLog.instance.logInfo("login ${result?.name}", popShow: false);
      return result;
    } on DioException catch (e, s) {
      AppLog.instance.logError('Check Login failed', e, s);
      _setError(_dioMessage(e));
    } catch (e, s) {
      AppLog.instance.logError('Check Login failed', e, s);
      _setError(e.toString());
    }
    return null;
  }

  Future<void> fetchLogin({required LoginPayload payload}) async {
    try {
      _setLoading();
      final result = await logincase(payload);
      AppLog.instance.logInfo(
        "Login ${result.success! ? "Success" : "Failed"}",
      );
      if (result.success != true || result.data?.user == null) {
        _setError(
          "Login gagal : ${result.message?.trim().isNotEmpty == true ? result.message : "Email atau kata sandi salah"}",
        );
        return;
      }
      user = result.data!.user;
      // Jangan panggil onFetchMyTenant() di sini karena ia memanggil
      // _setLoading() lagi (status flicker loading->loading) dan
      // kegagalannya menimpa status. Ambil tenant inline tanpa
      // me-reset loading supaya alur login atomik:
      // loading -> loggedIn ATAU loading -> error (tidak pernah stuck).
      try {
        final tenant = await getMyTenantUsecase();
        if (tenant == null) {
          _setError('Login berhasil tapi data restoran tidak ditemukan.');
          return;
        }
        debugPrint("authProvider : $tenant");
        await initLocalMyTenant(tenant);
        authStatus = AuthStatus.loggedIn;
        status = AuthStatus.loggedIn;
        errorMessage = null;
        notifyListeners();
      } on DioException catch (e, s) {
        AppLog.instance.logError('MyTenant after login failed', e, s);
        _setError(_dioMessage(e));
      } catch (e, s) {
        AppLog.instance.logError('MyTenant after login failed', e, s);
        _setError(e.toString());
      }
    } on DioException catch (e, s) {
      AppLog.instance.logError('DioException Login failed', e, s);
      _setError(_dioMessage(e));
    } catch (e, s) {
      AppLog.instance.logError('Login failed', e, s);
      _setError(e.toString());
    }
  }

  Future<void> onGetProfile() async {
    try {
      _setLoading();
      final result = await getProfileUsecase();
      user = result;
      authStatus = AuthStatus.loggedIn;
      status = AuthStatus.loggedIn;
      errorMessage = null;
      notifyListeners();
    } on DioException catch (e, s) {
      AppLog.instance.logError('Get Profile failed', e, s);
      _setError(_dioMessage(e));
    } catch (e, s) {
      AppLog.instance.logError('Get Profile failed', e, s);
      _setError(e.toString());
    }
  }

  // Future<void> initLocalMyTenant(TenantEntity myTenant) async {
  //   tenant = myTenant;
  //   final prefs = SharedPrefServices.pref;
  //   await prefs.setString(SettingsKeys.restaurantName, tenant!.name.trim());
  //   // address/phone/logo boleh null dari server — jangan pakai `!`
  //   // supaya tidak lempar _TypeError yang nyangkut di loading.
  //   await prefs.setString(
  //     SettingsKeys.restaurantAddress,
  //     (tenant!.address ?? '').trim(),
  //   );
  //   await prefs.setString(
  //     SettingsKeys.restaurantPhone,
  //     (tenant!.phone ?? '').trim(),
  //   );
  //   final logo = (tenant!.logoUrl ?? '').trim();
  //   if (logo.isNotEmpty) {
  //     await prefs.setString(SettingsKeys.restaurantLogo, logo);
  //   }
  //   final qris = (tenant!.qrisUrl ?? '').trim();
  //   //if (qris.isNotEmpty) {
  //   await prefs.setString(SettingsKeys.restaurantQris, qris);
  //   //}
  // }

  Future<void> logOut() async {
    try {
      _setLoading();
      await logoutcase();
      user = null;
      authStatus = AuthStatus.loggedOut;
      status = AuthStatus.loggedOut;
      errorMessage = null;
      notifyListeners();
    } on DioException catch (e, s) {
      AppLog.instance.logError('logOut failed', e, s);
      _setError(_dioMessage(e));
    } catch (e, s) {
      AppLog.instance.logError('logOut failed', e, s);
      _setError(e.toString());
    }
  }
}
