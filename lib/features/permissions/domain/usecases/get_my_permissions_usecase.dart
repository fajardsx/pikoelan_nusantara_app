import '../entities/role_permission_entity.dart';
import '../repositories/permission_repositories.dart';

class GetMyPermissionsUsecase {
  final PermissionRepository repository;
  const GetMyPermissionsUsecase(this.repository);

  Future<List<RolePermissionEntity>> call({bool forceRefresh = false}) async =>
      repository.getMyPermissions(forceRefresh: forceRefresh);
}
