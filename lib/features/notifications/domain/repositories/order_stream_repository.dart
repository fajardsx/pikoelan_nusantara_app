import '../entities/order_stream_event.dart';

abstract class OrderStreamRepository {
  /// Stream event order realtime. Implementasi bertanggung jawab melakukan
  /// reconnect otomatis sampai [disconnect] dipanggil.
  Stream<OrderStreamEvent> watchOrders({required String jwt});

  Future<void> disconnect();
}
