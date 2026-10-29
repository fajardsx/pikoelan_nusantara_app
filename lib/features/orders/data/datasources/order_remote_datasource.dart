import '../../../../core/configs/api_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../models/create_order_payload.dart';
import '../models/menu_items_response.dart';
import '../models/order_response.dart';
import '../models/orders_response.dart';

abstract class OrderRemoteDataSource {
  Future<OrdersResponse> getOrders({
    String? status,
    bool refresh,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<OrderResponse> createOrder(CreateOrderPayload payload);
  Future<OrderResponse> updateOrderStatus(
    int orderId,
    String status,
    String paymentMethod,
    bool paymentConfirmation,
  );
  Future<MenuItemsResponse> getAvailableMenuItems();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  @override
  Future<OrdersResponse> getOrders({
    String? status,
    bool refresh = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Format & key query disamakan dengan DashboardRemoteDataSource
    // (GET api/orders?status=..&startDate=yyyy-MM-dd&endDate=yyyy-MM-dd).
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final query = <String, dynamic>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (startDate != null) 'startDate': fmt(startDate),
      if (endDate != null) 'endDate': fmt(endDate),
    };
    final res = await DioClient.instance.get(
      ApiKeys.orders,
      queryParameters: query.isEmpty ? null : query,
      forceRefresh: refresh,
    );
    return OrdersResponse.fromJson(res.data);
  }

  @override
  Future<OrderResponse> createOrder(CreateOrderPayload payload) async {
    final res = await DioClient.instance.post(
      ApiKeys.orders,
      data: payload.toJson(),
    );
    return OrderResponse.fromJson(res.data);
  }

  @override
  Future<OrderResponse> updateOrderStatus(
    int orderId,
    String status,
    String paymentMethod,
    bool paymentConfirmation,
  ) async {
    final res = await DioClient.instance.put(
      ApiKeys.orderStatus(orderId),
      data: {
        'status': status,
        'paymentMethod': paymentMethod,
        'paymentConfirmation': paymentConfirmation,
      },
    );
    return OrderResponse.fromJson(res.data);
  }

  @override
  Future<MenuItemsResponse> getAvailableMenuItems() async {
    final res = await DioClient.instance.get(
      ApiKeys.menuItems,
      queryParameters: {'available': true},
    );
    return MenuItemsResponse.fromJson(res.data);
  }
}
