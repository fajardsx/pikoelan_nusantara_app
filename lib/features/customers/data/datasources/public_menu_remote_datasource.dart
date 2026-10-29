import 'package:restauran_menu/core/configs/api_keys.dart';
import 'package:restauran_menu/core/network/dio_client.dart';
import 'package:restauran_menu/features/orders/data/models/create_order_payload.dart';
import 'package:restauran_menu/features/orders/data/models/order_response.dart';
import 'package:restauran_menu/features/orders/data/models/orders_response.dart';

import '../models/public_menu_response.dart';

/// Remote source untuk alur publik Customer Self-Order (tanpa login).
///
/// GET    -> [ApiKeys.menuPublic]        `api/menu/:slug`
/// POST   -> [ApiKeys.menuPublicOrder]  `api/menu/:slug/order`
/// DELETE -> [ApiKeys.menuPublicOrder]  `api/menu/:slug/order?order_number=...`
/// GET    -> [ApiKeys.menuPublicMyOrder] `api/public/menu/:slug/my_orders`
abstract class PublicMenuRemoteDataSource {
  Future<PublicMenuResponse> getPublicMenu(
    String slug, {
    bool forceRefresh = false,
  });
  Future<OrderResponse> createPublicOrder(
    String slug,
    CreateOrderPayload payload,
  );
  Future<OrdersResponse> getPublicOrders(
    String slug, {
    String? orderNumber,
  });
  Future<OrderResponse> cancelPublicOrder(
    String slug,
    String orderNumber,
  );
}

class PublicMenuRemoteDataSourceImpl implements PublicMenuRemoteDataSource {
  @override
  Future<PublicMenuResponse> getPublicMenu(
    String slug, {
    bool forceRefresh = false,
  }) async {
    final res = await DioClient.instance.get(
      ApiKeys.menuPublic(slug),
      forceRefresh: forceRefresh,
    );
    final json = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{'data': res.data};
    return PublicMenuResponse.fromJson(json);
  }

  @override
  Future<OrderResponse> createPublicOrder(
    String slug,
    CreateOrderPayload payload,
  ) async {
    final res = await DioClient.instance.post(
      ApiKeys.menuPublicOrder(slug),
      data: payload.toJson(),
    );
    final json = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{'data': res.data};
    return OrderResponse.fromJson(json);
  }

  @override
  Future<OrdersResponse> getPublicOrders(
    String slug, {
    String? orderNumber,
  }) async {
    final query = <String, dynamic>{
      if (orderNumber != null && orderNumber.trim().isNotEmpty)
        'order_number': orderNumber.trim(),
    };
    final res = await DioClient.instance.get(
      ApiKeys.menuPublicMyOrder(slug),
      queryParameters: query.isEmpty ? null : query,
    );
    final json = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{'data': res.data};
    return OrdersResponse.fromJson(json);
  }

  @override
  Future<OrderResponse> cancelPublicOrder(
    String slug,
    String orderNumber,
  ) async {
    final res = await DioClient.instance.delete(
      ApiKeys.menuPublicOrder(slug),
      queryParameters: {'order_number': orderNumber.trim()},
    );
    final json = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{'data': res.data};
    return OrderResponse.fromJson(json);
  }
}
