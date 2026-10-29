import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/role_permission_entity.dart';

/// Response untuk `GET api/permissions/me`, `PUT api/permissions/:role`,
/// dan `DELETE api/permissions/:role`.
/// Ketiganya mengembalikan `data.permissions` dengan bentuk yang sama.
class RolePermissionsResponse extends AppBaseResponse<List<RolePermissionEntity>> {
  RolePermissionsResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory RolePermissionsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawList = rawData is Map ? rawData['permissions'] as List? : null;

    return RolePermissionsResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data:
          rawList
              ?.whereType<Map>()
              .map(
                (item) =>
                    RolePermissionEntity.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          const [],
    );
  }
}
