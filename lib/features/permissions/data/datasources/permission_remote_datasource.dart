import '../../../../core/configs/api_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../models/role_permission_payload.dart';
import '../models/role_permission_matrix_response.dart';
import '../models/role_permissions_response.dart';

abstract class PermissionRemoteDataSource {
  /// GET api/permissions
  Future<RolePermissionMatrixResponse> getPermissionMatrix({
    bool forceRefresh = false,
    int? tenantId,
  });

  /// GET api/permissions/me
  Future<RolePermissionsResponse> getMyPermissions({
    bool forceRefresh = false,
  });

  /// PUT api/permissions/:role
  Future<RolePermissionsResponse> updateRolePermissions(
    String role,
    RolePermissionPayload payload,
  );

  /// DELETE api/permissions/:role
  Future<RolePermissionsResponse> resetRolePermissions(
    String role, {
    int? tenantId,
  });
}

class PermissionRemoteDataSourceImpl implements PermissionRemoteDataSource {
  @override
  Future<RolePermissionMatrixResponse> getPermissionMatrix({
    bool forceRefresh = false,
    int? tenantId,
  }) async {
    final res = await DioClient.instance.get(
      ApiKeys.permissions,
      queryParameters: tenantId != null ? {'tenantId': tenantId} : null,
      forceRefresh: forceRefresh,
    );
    return RolePermissionMatrixResponse.fromJson(res.data);
  }

  @override
  Future<RolePermissionsResponse> getMyPermissions({
    bool forceRefresh = false,
  }) async {
    final res = await DioClient.instance.get(
      ApiKeys.myPermissions,
      forceRefresh: forceRefresh,
    );
    return RolePermissionsResponse.fromJson(res.data);
  }

  @override
  Future<RolePermissionsResponse> updateRolePermissions(
    String role,
    RolePermissionPayload payload,
  ) async {
    final res = await DioClient.instance.put(
      ApiKeys.rolePermissions(role),
      data: payload.toJson(),
      forceRefresh: true,
    );
    return RolePermissionsResponse.fromJson(res.data);
  }

  @override
  Future<RolePermissionsResponse> resetRolePermissions(
    String role, {
    int? tenantId,
  }) async {
    final res = await DioClient.instance.delete(
      ApiKeys.rolePermissions(role),
      data: tenantId != null ? {'tenantId': tenantId} : null,
      queryParameters: tenantId != null ? {'tenantId': tenantId} : null,
      forceRefresh: true,
    );
    return RolePermissionsResponse.fromJson(res.data);
  }
}
