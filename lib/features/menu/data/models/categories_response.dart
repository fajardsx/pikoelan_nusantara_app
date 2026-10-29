import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/menu_category_entity.dart';

class CategoriesResponse extends AppBaseResponse<List<MenuCategoryEntity>> {
  CategoriesResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] != null
        ? json['data']['categories'] as List?
        : null;
    return CategoriesResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: list?.map((c) => MenuCategoryEntity.fromJson(c)).toList() ?? [],
    );
  }
}
