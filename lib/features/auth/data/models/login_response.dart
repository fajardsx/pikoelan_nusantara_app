import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/auth_entities.dart';

class LoginResponse extends AppBaseResponse<AuthEntity> {
  LoginResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? AuthEntity.fromJson(json['data']) : null,
    );
  }
}
