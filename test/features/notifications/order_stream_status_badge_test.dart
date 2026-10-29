import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/database/order_repository.dart';
import 'package:restauran_menu/features/notifications/domain/entities/order_stream_event.dart';
import 'package:restauran_menu/features/notifications/domain/usecases/watch_order_stream_usecase.dart';
import 'package:restauran_menu/features/notifications/presentation/provider/order_stream_provider.dart';
import 'package:restauran_menu/features/notifications/presentation/widgets/order_stream_status_badge.dart';

/// Tidak dipakai oleh test badge; hanya memenuhi konstruktor provider.
class _NoopWatchUsecase implements WatchOrderStreamUsecase {
  @override
  Stream<OrderStreamEvent> call() => const Stream<OrderStreamEvent>.empty();

  @override
  Future<void> disconnect() async {}
}

class _NoopOrderRepository implements OrderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('OrderStreamStatusBadge', () {
    late OrderStreamProvider provider;

    setUp(() {
      provider = OrderStreamProvider(
        _NoopWatchUsecase(),
        _NoopOrderRepository(),
      );
    });

    tearDown(() => provider.dispose());

    Widget wrap(Widget child) {
      return ChangeNotifierProvider<OrderStreamProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(body: Center(child: child)),
        ),
      );
    }

    testWidgets('menampilkan label status dari provider', (tester) async {
      provider.connectionStatus = OrderStreamConnectionStatus.connected;

      await tester.pumpWidget(wrap(const OrderStreamStatusBadge()));

      expect(find.text('Realtime aktif'), findsOneWidget);
    });

    testWidgets('compact menyembunyikan label teks', (tester) async {
      provider.connectionStatus = OrderStreamConnectionStatus.reconnecting;

      await tester.pumpWidget(
        wrap(const OrderStreamStatusBadge(compact: true)),
      );

      expect(find.text('Menyambung ulang'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('gaya onDark tetap menampilkan label', (tester) async {
      provider.connectionStatus = OrderStreamConnectionStatus.failed;

      await tester.pumpWidget(
        wrap(
          const ColoredBox(
            color: Colors.black,
            child: OrderStreamStatusBadge(onDark: true),
          ),
        ),
      );

      expect(find.text('Terputus'), findsOneWidget);
    });
  });
}
