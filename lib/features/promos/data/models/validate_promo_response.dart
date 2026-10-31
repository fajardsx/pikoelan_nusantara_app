import 'package:restauran_menu/core/network/models/app_base_response.dart';

import '../../domain/entities/promo_entity.dart';

class ValidatePromoResponse extends AppBaseResponse<Map<String, dynamic>> {
  final bool valid;
  final String? dataMessage;
  final double? discountAmount;
  final PromoEntity? promo;

  ValidatePromoResponse({
    required super.code,
    required super.success,
    required super.message,
    required super.data,
    required this.valid,
    this.dataMessage,
    this.discountAmount,
    this.promo,
  });

  factory ValidatePromoResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ValidatePromoResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: data as Map<String, dynamic>?,
      valid: data!['valid'] as bool? ?? false,
      dataMessage: data['message'] as String?,
      discountAmount: (data['discountAmount'] as num?)?.toDouble(),
      promo: data['promo'] != null ? PromoEntity.fromJson(data['promo']) : null,
    );
  }
}
