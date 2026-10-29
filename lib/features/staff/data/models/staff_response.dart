import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/staff_entity.dart';

class StaffResponse extends AppBaseResponse<StaffEntity> {
  StaffResponse({required super.code, required super.message, required super.data, required super.success});

  factory StaffResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['data'] != null ? json['data']['user'] : null;
    return StaffResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: userJson != null ? StaffEntity.fromJson(userJson) : null,
    );
  }
}
