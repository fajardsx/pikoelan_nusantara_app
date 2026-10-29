import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/list_user_entities.dart';

class GetAllUserResponse extends AppBaseResponse<ListUserEntity> {
  GetAllUserResponse({
    required super.code,
    required super.success,
    required super.message,
    required super.data,
  });

  factory GetAllUserResponse.fromJson(Map<String, dynamic> json) {
    return GetAllUserResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: ListUserEntity.fromJson(json['data']),
    );
  }
}
