import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/staff_entity.dart';

class StaffListResponse extends AppBaseResponse<List<StaffEntity>> {
  StaffListResponse({required super.code, required super.message, required super.data, required super.success});

  factory StaffListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] != null ? json['data']['users'] as List? : null;
    return StaffListResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: list?.map((u) => StaffEntity.fromJson(u)).toList() ?? [],
    );
  }
}
