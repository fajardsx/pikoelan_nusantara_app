import '../../../../core/network/models/app_base_response.dart';
import '../../domain/entities/order_entity.dart';

class OrderResponse extends AppBaseResponse<OrderEntity> {
  OrderResponse({
    required super.code,
    required super.message,
    required super.data,
    required super.success,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? orderJson;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      if (data['order'] is Map) {
        orderJson = Map<String, dynamic>.from(data['order'] as Map);
      } else if (data.containsKey('id') || data.containsKey('orderNumber')) {
        // Backend mengembalikan order langsung di `data`.
        orderJson = data;
      }
    } else if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      if (m['order'] is Map) {
        orderJson = Map<String, dynamic>.from(m['order'] as Map);
      } else if (m.containsKey('id') || m.containsKey('orderNumber')) {
        orderJson = m;
      }
    }
    // Fallback: root json sendiri adalah order.
    orderJson ??= (json.containsKey('id') || json.containsKey('orderNumber'))
        ? json
        : null;
    return OrderResponse(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: orderJson != null ? OrderEntity.fromJson(orderJson) : null,
    );
  }
}
