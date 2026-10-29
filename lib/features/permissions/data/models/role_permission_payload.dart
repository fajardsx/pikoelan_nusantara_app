import '../../domain/entities/role_permission_entity.dart';

/// Body untuk `PUT api/permissions/:role`.
/// `tenantId` hanya dipakai kalau user yang login superadmin.
class RolePermissionPayload {
  final List<RolePermissionEntity> permissions;
  final int? tenantId;

  const RolePermissionPayload({required this.permissions, this.tenantId});

  Map<String, dynamic> toJson() {
    return {
      'permissions': permissions.map((item) => item.toJson()).toList(),
      if (tenantId != null) 'tenantId': tenantId,
    };
  }
}
