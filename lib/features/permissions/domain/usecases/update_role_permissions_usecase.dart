import '../entities/role_permission_entity.dart';
import '../repositories/permission_repositories.dart';

class UpdateRolePermissionsUsecase {
  final PermissionRepository repository;
  const UpdateRolePermissionsUsecase(this.repository);

  Future<List<RolePermissionEntity>> call({
    required String role,
    required List<RolePermissionEntity> permissions,
    int? tenantId,
  }) async => repository.updateRolePermissions(
    role: role,
    permissions: permissions,
    tenantId: tenantId,
  );
}
