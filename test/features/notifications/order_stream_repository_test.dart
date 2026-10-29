import 'package:flutter_test/flutter_test.dart';
import 'package:restauran_menu/features/notifications/data/datasources/order_stream_remote_datasource.dart';
import 'package:restauran_menu/features/notifications/data/models/order_stream_message_model.dart';
import 'package:restauran_menu/features/notifications/data/repositories/order_stream_repository_impl.dart';
import 'package:restauran_menu/features/notifications/domain/entities/order_stream_event.dart';
import 'package:restauran_menu/features/notifications/domain/entities/order_stream_role.dart';
import 'package:restauran_menu/features/orders/domain/entities/order_entity.dart';

class _FakeRemoteDataSource implements OrderStreamRemoteDataSource {
  _FakeRemoteDataSource(this.messages);

  final List<OrderStreamMessageModel> messages;
  String? lastJwt;
  int disconnectCount = 0;

  @override
  Stream<OrderStreamMessageModel> watchOrders({required String jwt}) {
    lastJwt = jwt;
    return Stream<OrderStreamMessageModel>.fromIterable(messages);
  }

  @override
  Future<void> disconnect() async {
    disconnectCount++;
  }
}

void main() {
  group('OrderStreamRepositoryImpl', () {
    test('maps transport events and forwards jwt', () async {
      final remote = _FakeRemoteDataSource([
        const OrderStreamMessageModel(transport: OrderStreamTransport.open),
        const OrderStreamMessageModel(
          transport: OrderStreamTransport.reconnecting,
          attempt: 2,
          retryDelay: Duration(seconds: 4),
        ),
        const OrderStreamMessageModel(
          transport: OrderStreamTransport.error,
          statusCode: 401,
          errorMessage: 'unauthorized',
        ),
      ]);
      final repository = OrderStreamRepositoryImpl(remote);

      final events = await repository.watchOrders(jwt: 'jwt-123').toList();

      expect(remote.lastJwt, 'jwt-123');
      expect(events[0].type, OrderStreamEventType.connected);
      expect(events[1].type, OrderStreamEventType.reconnecting);
      expect(events[1].attempt, 2);
      expect(events[2].type, OrderStreamEventType.failed);
    });

    test('maps a full order payload and normalizes status', () async {
      final remote = _FakeRemoteDataSource([
        const OrderStreamMessageModel(
          transport: OrderStreamTransport.message,
          event: 'order.created',
          payload: {
            'data': {
              'id': 12,
              'orderNumber': '#0012',
              'orderType': 'dine_in',
              'tableNumber': 4,
              'status': 'baru',
              'source': 'customer',
              'totalAmount': 45000,
              'items': [
                {
                  'id': 1,
                  'menuItemId': 3,
                  'name': 'Nasi Goreng',
                  'price': 45000,
                  'quantity': 1,
                },
              ],
            },
          },
        ),
      ]);
      final repository = OrderStreamRepositoryImpl(remote);

      final event = (await repository.watchOrders(jwt: 'jwt').toList()).single;

      expect(event.type, OrderStreamEventType.orderCreated);
      expect(event.orderNumber, '#0012');
      expect(event.status, OrderEntity.statusNew);
      expect(event.order?.orderNumber, '#0012');
      expect(event.order?.items, hasLength(1));
      expect(event.order?.totalAmount, 45000);
    });

    test(
      'maps a partial status payload without overwriting the order',
      () async {
        final remote = _FakeRemoteDataSource([
          const OrderStreamMessageModel(
            transport: OrderStreamTransport.message,
            event: 'order.status',
            payload: {'orderNumber': '#0012', 'status': 'siap'},
          ),
        ]);
        final repository = OrderStreamRepositoryImpl(remote);

        final event =
            (await repository.watchOrders(jwt: 'jwt').toList()).single;

        expect(event.type, OrderStreamEventType.orderUpdated);
        expect(event.order, isNull);
        expect(event.orderNumber, '#0012');
        expect(event.status, OrderEntity.statusReady);
      },
    );

    test('maps stats payload', () async {
      final remote = _FakeRemoteDataSource([
        const OrderStreamMessageModel(
          transport: OrderStreamTransport.message,
          event: 'stats',
          payload: {
            'stats': {
              'totalOrders': 10,
              'newOrders': 3,
              'readyOrders': '2',
              'revenueToday': 150000.5,
            },
          },
        ),
      ]);
      final repository = OrderStreamRepositoryImpl(remote);

      final event = (await repository.watchOrders(jwt: 'jwt').toList()).single;

      expect(event.type, OrderStreamEventType.stats);
      expect(event.stats?.totalOrders, 10);
      expect(event.stats?.newOrders, 3);
      expect(event.stats?.readyOrders, 2);
      expect(event.stats?.revenueToday, 150000.5);
    });

    test('treats stats.updated with nested data as stats', () async {
      final remote = _FakeRemoteDataSource([
        const OrderStreamMessageModel(
          transport: OrderStreamTransport.message,
          event: 'stats.updated',
          payload: {
            'data': {'totalOrders': 4, 'newOrders': 1},
          },
        ),
      ]);
      final repository = OrderStreamRepositoryImpl(remote);

      final event = (await repository.watchOrders(jwt: 'jwt').toList()).single;

      expect(event.type, OrderStreamEventType.stats);
      expect(event.stats?.totalOrders, 4);
      expect(event.stats?.newOrders, 1);
    });

    test('disconnect is delegated to the datasource', () async {
      final remote = _FakeRemoteDataSource([]);
      final repository = OrderStreamRepositoryImpl(remote);

      await repository.disconnect();

      expect(remote.disconnectCount, 1);
    });
  });

  group('OrderStreamEvent relevance', () {
    OrderStreamEvent event(String status) => OrderStreamEvent(
      type: OrderStreamEventType.orderUpdated,
      receivedAt: DateTime(2026, 10, 21),
      status: status,
    );

    test('kitchen ignores deliver/completed events', () {
      expect(
        event(OrderEntity.statusNew).isRelevantFor(OrderStreamRole.kitchen),
        isTrue,
      );
      expect(
        event(OrderEntity.statusProses).isRelevantFor(OrderStreamRole.kitchen),
        isTrue,
      );
      expect(
        event(OrderEntity.statusReady).isRelevantFor(OrderStreamRole.kitchen),
        isTrue,
      );
      expect(
        event(OrderEntity.statusDeliver).isRelevantFor(OrderStreamRole.kitchen),
        isFalse,
      );
      expect(
        event(
          OrderEntity.statusCompleted,
        ).isRelevantFor(OrderStreamRole.kitchen),
        isFalse,
      );
    });

    test('kasir and waiter accept all order events', () {
      expect(
        event(OrderEntity.statusCompleted).isRelevantFor(OrderStreamRole.kasir),
        isTrue,
      );
      expect(
        event(
          OrderEntity.statusCompleted,
        ).isRelevantFor(OrderStreamRole.waiter),
        isTrue,
      );
    });
  });

  group('OrderStreamRole', () {
    test('maps backend role labels', () {
      expect(OrderStreamRole.fromUserRole('kasir'), OrderStreamRole.kasir);
      expect(OrderStreamRole.fromUserRole('Kitchen'), OrderStreamRole.kitchen);
      expect(OrderStreamRole.fromUserRole('waiter'), OrderStreamRole.waiter);
      expect(OrderStreamRole.fromUserRole('admin'), isNull);
    });
  });
}
