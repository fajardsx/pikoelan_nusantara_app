import '../entities/permission_matrix_entity.dart';
import '../repositories/permission_repositories.dart';

class GetPermissionMatrixUsecase {
  final PermissionRepository repository;
  const GetPermissionMatrixUsecase(this.repository);

  Future<PermissionMatrixEntity> call({
    bool forceRefresh = false,
    int? tenantId,
  }) async => repository.getPermissionMatrix(
    forceRefresh: forceRefresh,
    tenantId: tenantId,
  );
}
