import 'package:restauran_menu/core/network/models/app_base_response.dart';

import '../../domain/entities/member_entity.dart';

class ValidateMemberResponse extends AppBaseResponse<Map<String, dynamic>> {
  ValidateMemberResponse({
    required super.code,
    required super.success,
    required super.message,
    required super.data,
  });

  factory ValidateMemberResponse.fromJson(Map<String, dynamic> json) {
    var datas = {
      "isMember": json['data']['isMember'] as bool,
      "isActive": json['data']['isActive'] as bool,
      "member": MemberEntity.fromJson(
        json['data']['member'] as Map<String, dynamic>,
      ),
    };
    return ValidateMemberResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: datas,
    );
  }
}
