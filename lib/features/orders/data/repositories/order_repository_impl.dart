import '../../data/models/create_order_payload.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_menu_item_entity.dart';
import '../../domain/repositories/order_data_repositories.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderDataRepository {
  final OrderRemoteDataSource remoteDataSource;
  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OrderEntity>> getOrders({
    String? status,
    bool refresh = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final res = await remoteDataSource.getOrders(
      status: status,
      refresh: refresh,
      startDate: startDate,
      endDate: endDate,
    );
    return res.data ?? [];
  }

  @override
  Future<OrderEntity?> createOrder(CreateOrderPayload payload) async {
    final res = await remoteDataSource.createOrder(payload);
    return res.data;
  }

  @override
  Future<OrderEntity?> updateOrderStatus(
    int orderId,
    String status,
    String paymentMethod,
    bool paymentConfirmation,
  ) async {
    final res = await remoteDataSource.updateOrderStatus(
      orderId,
      status,
      paymentMethod,
      paymentConfirmation,
    );
    return res.data;
  }

  @override
  Future<List<OrderMenuItemEntity>> getAvailableMenuItems() async {
    final res = await remoteDataSource.getAvailableMenuItems();
    return res.data ?? [];
  }
}
