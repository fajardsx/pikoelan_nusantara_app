import 'package:image_picker/image_picker.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_payment_entity.dart';

import '../entities/tenant_entity.dart';
import '../repositories/dashboard_repositories.dart';

class UpdateMyTenantUsecase {
  final DashboardRepository repository;
  const UpdateMyTenantUsecase(this.repository);

  Future<TenantEntity?> call({
    required String name,
    String? slug,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    XFile? logoFile,
    String? qrisUrl,
    XFile? qrisFile,
    String? rekening,
    TenantPaymentEntity? tenantPayment,
  }) {
    return repository.updateMyTenant(
      name: name,
      slug: slug,
      address: address,
      phone: phone,
      email: email,
      logoUrl: logoUrl,
      logoFile: logoFile,
      qrisUrl: qrisUrl,
      qrisFile: qrisFile,
      rekening: rekening,
      tenantPayment: tenantPayment,
    );
  }
}
