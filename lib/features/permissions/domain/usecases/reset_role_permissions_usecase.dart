import '../entities/role_permission_entity.dart';
import '../repositories/permission_repositories.dart';

class ResetRolePermissionsUsecase {
  final PermissionRepository repository;
  const ResetRolePermissionsUsecase(this.repository);

  Future<List<RolePermissionEntity>> call({
    required String role,
    int? tenantId,
  }) async => repository.resetRolePermissions(role: role, tenantId: tenantId);
}
