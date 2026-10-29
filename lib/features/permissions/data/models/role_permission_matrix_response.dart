import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/permission_matrix_entity.dart';

class RolePermissionMatrixResponse
    extends AppBaseResponse<PermissionMatrixEntity> {
  RolePermissionMatrixResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory RolePermissionMatrixResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return RolePermissionMatrixResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: rawData is Map
          ? PermissionMatrixEntity.fromJson(Map<String, dynamic>.from(rawData))
          : null,
    );
  }
}
