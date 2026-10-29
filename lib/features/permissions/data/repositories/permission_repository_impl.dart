import 'package:dio/dio.dart';

import '../../domain/entities/permission_matrix_entity.dart';
import '../../domain/entities/role_permission_entity.dart';
import '../../domain/repositories/permission_repositories.dart';
import '../datasources/permission_remote_datasource.dart';
import '../models/role_permission_payload.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionRemoteDataSource remoteDataSource;
  PermissionRepositoryImpl(this.remoteDataSource);

  @override
  Future<PermissionMatrixEntity> getPermissionMatrix({
    bool forceRefresh = false,
    int? tenantId,
  }) async {
    try {
      final res = await remoteDataSource.getPermissionMatrix(
        forceRefresh: forceRefresh,
        tenantId: tenantId,
      );
      final data = res.data;
      if (data == null) {
        throw Exception(res.message ?? 'Gagal memuat privilege role');
      }
      return data;
    } catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<List<RolePermissionEntity>> getMyPermissions({
    bool forceRefresh = false,
  }) async {
    try {
      final res = await remoteDataSource.getMyPermissions(
        forceRefresh: forceRefresh,
      );
      return res.data ?? <RolePermissionEntity>[];
    } catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<List<RolePermissionEntity>> updateRolePermissions({
    required String role,
    required List<RolePermissionEntity> permissions,
    int? tenantId,
  }) async {
    try {
      final res = await remoteDataSource.updateRolePermissions(
        role,
        RolePermissionPayload(permissions: permissions, tenantId: tenantId),
      );
      return res.data ?? <RolePermissionEntity>[];
    } catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<List<RolePermissionEntity>> resetRolePermissions({
    required String role,
    int? tenantId,
  }) async {
    try {
      final res = await remoteDataSource.resetRolePermissions(
        role,
        tenantId: tenantId,
      );
      return res.data ?? <RolePermissionEntity>[];
    } catch (e) {
      throw _asException(e);
    }
  }

  /// Ubah error Dio jadi pesan yang enak ditampilkan di snackbar.
  /// Backend mengirim pesan validasi di `data.message`
  /// (lihat `sendResponse` di `src/utils/response.js`).
  Exception _asException(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return Exception(message);
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Koneksi ke server timeout, coba lagi');
        case DioExceptionType.connectionError:
          return Exception('Tidak ada koneksi ke server');
        default:
          return Exception(error.message ?? 'Terjadi kesalahan pada jaringan');
      }
    }
    if (error is Exception) return error;
    return Exception(error.toString());
  }
}
