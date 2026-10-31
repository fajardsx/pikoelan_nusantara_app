import 'package:restauran_menu/core/network/models/app_base_response.dart';

import '../../domain/entities/member_entity.dart';

class MemberResponse extends AppBaseResponse<MemberEntity> {
  final List<MemberEntity> items;

  MemberResponse({
    required super.code,
    required super.success,
    required super.message,
    required super.data,
    this.items = const [],
  });

  factory MemberResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    MemberEntity? single;
    List<MemberEntity> list = [];

    if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => MemberEntity.fromJson(e))
          .toList();
      if (list.isNotEmpty) single = list.first;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['members'] is List) {
        list = (rawData['members'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => MemberEntity.fromJson(e))
            .toList();
      } else if (rawData['items'] is List) {
        list = (rawData['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => MemberEntity.fromJson(e))
            .toList();
      } else {
        single = MemberEntity.fromJson(rawData);
        list = [single];
      }
    }

    return MemberResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: single,
      items: list,
    );
  }
}
