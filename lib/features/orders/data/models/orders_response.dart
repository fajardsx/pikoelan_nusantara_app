import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/order_entity.dart';

class OrdersResponse extends AppBaseResponse<List<OrderEntity>> {
  OrdersResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] != null ? json['data']['orders'] as List? : null;
    return OrdersResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: list?.map((o) => OrderEntity.fromJson(o)).toList() ?? [],
    );
  }
}
