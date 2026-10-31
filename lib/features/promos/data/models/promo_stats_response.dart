import 'package:restauran_menu/core/network/models/app_base_response.dart';

class PromoStatsResponse extends AppBaseResponse<Map<String, dynamic>> {
  final int? totalPromos;
  final int? activePromos;
  final int? totalUsages;
  final double? totalDiscountGiven;

  PromoStatsResponse({
    required super.code,
    required super.success,
    required super.message,
    required super.data,
    this.totalPromos,
    this.activePromos,
    this.totalUsages,
    this.totalDiscountGiven,
  });

  factory PromoStatsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> map = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return PromoStatsResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      totalPromos: (map['totalPromos'] as num?)?.toInt() ??
          (map['total'] as num?)?.toInt(),
      activePromos: (map['activePromos'] as num?)?.toInt() ??
          (map['active'] as num?)?.toInt(),
      totalUsages: (map['totalUsages'] as num?)?.toInt() ??
          (map['totalUsage'] as num?)?.toInt() ??
          (map['usages'] as num?)?.toInt(),
      totalDiscountGiven: (map['totalDiscountGiven'] as num?)?.toDouble() ??
          (map['discountGiven'] as num?)?.toDouble() ??
          (map['totalDiscount'] as num?)?.toDouble(),
    );
  }
}
