import '../../domain/entities/permission_matrix_entity.dart';
import '../../domain/entities/role_permission_entity.dart';

abstract class PermissionRepository {
  /// `GET api/permissions` -> matriks privilege semua role.
  Future<PermissionMatrixEntity> getPermissionMatrix({
    bool forceRefresh = false,
    int? tenantId,
  });

  /// `GET api/permissions/me` -> privilege user yang sedang login.
  Future<List<RolePermissionEntity>> getMyPermissions({
    bool forceRefresh = false,
  });

  /// `PUT api/permissions/:role` -> simpan override privilege satu role.
  Future<List<RolePermissionEntity>> updateRolePermissions({
    required String role,
    required List<RolePermissionEntity> permissions,
    int? tenantId,
  });

  /// `DELETE api/permissions/:role` -> kembalikan ke privilege default.
  Future<List<RolePermissionEntity>> resetRolePermissions({
    required String role,
    int? tenantId,
  });
}
