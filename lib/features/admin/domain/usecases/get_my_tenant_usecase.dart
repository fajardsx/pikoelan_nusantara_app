import '../entities/tenant_entity.dart';
import '../repositories/dashboard_repositories.dart';

class GetMyTenantUsecase {
  final DashboardRepository repository;
  const GetMyTenantUsecase(this.repository);

  Future<TenantEntity?> call() async {
    return repository.getMyTenant();
  }
}
