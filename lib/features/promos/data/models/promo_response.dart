import 'package:restauran_menu/core/network/models/app_base_response.dart';

import '../../domain/entities/promo_entity.dart';

class PromoResponse extends AppBaseResponse<PromoEntity> {
  final List<PromoEntity> items;

  PromoResponse({
    required super.code,
    required super.success,
    required super.message,
    required super.data,
    this.items = const [],
  });

  factory PromoResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    PromoEntity? single;
    List<PromoEntity> list = [];

    if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => PromoEntity.fromJson(e))
          .toList();
      if (list.isNotEmpty) single = list.first;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['promos'] is List) {
        list = (rawData['promos'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => PromoEntity.fromJson(e))
            .toList();
      } else if (rawData['items'] is List) {
        list = (rawData['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => PromoEntity.fromJson(e))
            .toList();
      } else {
        single = PromoEntity.fromJson(rawData);
        list = [single];
      }
    }

    return PromoResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: single,
      items: list,
    );
  }
}
