import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/order_menu_item_entity.dart';

class MenuItemsResponse extends AppBaseResponse<List<OrderMenuItemEntity>> {
  MenuItemsResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory MenuItemsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] != null ? json['data']['items'] as List? : null;
    return MenuItemsResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: list?.map((i) => OrderMenuItemEntity.fromJson(i)).toList() ?? [],
    );
  }
}
