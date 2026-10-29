import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/menu_item_entity.dart';

class MenuItemResponse extends AppBaseResponse<MenuItemEntity> {
  MenuItemResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory MenuItemResponse.fromJson(Map<String, dynamic> json) {
    final itemJson = json['data'] != null ? json['data']['item'] : null;
    return MenuItemResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: itemJson != null ? MenuItemEntity.fromJson(itemJson) : null,
    );
  }
}
