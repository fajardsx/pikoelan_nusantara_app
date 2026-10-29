import '../../data/models/create_order_payload.dart';
import '../entities/order_entity.dart';
import '../entities/order_menu_item_entity.dart';

abstract class OrderDataRepository {
  Future<List<OrderEntity>> getOrders({
    String? status,
    bool refresh,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<OrderEntity?> createOrder(CreateOrderPayload payload);
  Future<OrderEntity?> updateOrderStatus(
    int orderId,
    String status,
    String paymentMethod,
    bool paymentConfirmation,
  );
  Future<List<OrderMenuItemEntity>> getAvailableMenuItems();
}
