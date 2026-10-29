import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/tenant_entity.dart';

class TenantResponse extends AppBaseResponse<TenantEntity> {
  TenantResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory TenantResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    // GET /tenants/me -> { data: { tenant: {...} } }
    // PUT /tenants/me -> bisa { data: { tenant: {...} } } ATAU { data: {...} }
    Map<String, dynamic>? tenantJson;
    if (rawData is Map<String, dynamic>) {
      final nested = rawData['tenant'];
      if (nested is Map<String, dynamic>) {
        tenantJson = nested;
      } else {
        tenantJson = rawData;
      }
    }
    return TenantResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: tenantJson != null && tenantJson.containsKey('id')
          ? TenantEntity.fromJson(tenantJson)
          : null,
    );
  }
}
