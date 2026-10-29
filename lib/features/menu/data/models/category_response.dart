import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/menu_category_entity.dart';

class CategoryResponse extends AppBaseResponse<MenuCategoryEntity> {
  CategoryResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    final catJson = json['data'] != null ? json['data']['category'] : null;
    return CategoryResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: catJson != null ? MenuCategoryEntity.fromJson(catJson) : null,
    );
  }
}
