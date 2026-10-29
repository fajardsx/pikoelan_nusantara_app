import '../../../../core/configs/api_keys.dart';
import '../../../../core/network/sse/sse_client.dart';
import '../models/order_stream_message_model.dart';

abstract class OrderStreamRemoteDataSource {
  Stream<OrderStreamMessageModel> watchOrders({required String jwt});

  Future<void> disconnect();
}

class OrderStreamRemoteDataSourceImpl implements OrderStreamRemoteDataSource {
  OrderStreamRemoteDataSourceImpl(this._sseClient);

  final SseClient _sseClient;

  @override
  Stream<OrderStreamMessageModel> watchOrders({required String jwt}) {
    return _sseClient
        .connect(SseConfig(path: ApiKeys.orderStream(jwt)))
        .map(OrderStreamMessageModel.fromSse);
  }

  @override
  Future<void> disconnect() => _sseClient.disconnect();
}
