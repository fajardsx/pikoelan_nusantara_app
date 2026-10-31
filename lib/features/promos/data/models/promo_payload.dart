import 'package:dio/dio.dart';

class PromoPayload {
  final String code;
  final String title;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? applicableTier; // 'all' or tier name
  final bool? isActive;
  //final XFile? imageFile;

  PromoPayload({
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.usageLimit,
    this.startDate,
    this.endDate,
    this.applicableTier,
    this.isActive,
    //this.imageFile,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'code': code,
      'title': title,
      if (description != null) 'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
      if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount,
      if (usageLimit != null) 'usageLimit': usageLimit,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (applicableTier != null) 'applicableTier': applicableTier,
      if (isActive != null) 'isActive': isActive,
      // if (imageFile != null)
      //   'image': MultipartFile.fromBytes(
      //     await imageFile!.readAsBytes(),
      //     filename: 'image.jpg',
      //   ),
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      if (description != null) 'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      if (minOrderAmount != null) 'minOrderAmount': minOrderAmount,
      if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount,
      if (usageLimit != null) 'usageLimit': usageLimit,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (applicableTier != null) 'applicableTier': applicableTier,
      if (isActive != null) 'isActive': isActive,
      // image handling can be added here later if required.
    };
  }
}
