import 'package:restauran_menu/core/common/common_utils.dart';

class PromoEntity {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final int usageCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String applicableTier;
  final bool isActive;

  PromoEntity({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    required this.usageCount,
    this.startDate,
    this.endDate,
    required this.applicableTier,
    required this.isActive,
  });

  factory PromoEntity.fromJson(Map<String, dynamic> json) {
    return PromoEntity(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      discountType: json['discountType'] as String? ?? 'percentage',
      discountValue: (toDouble(json['discountValue'])),
      //discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: json['minOrderAmount'] != null
          ? (toDouble(json['minOrderAmount']))
          : null,
      maxDiscountAmount: json['maxDiscountAmount'] != null
          ? toDouble(json['maxDiscountAmount'])
          : null,
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      applicableTier: json['applicableTier'] as String? ?? 'all',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
