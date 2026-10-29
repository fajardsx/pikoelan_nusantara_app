import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:restauran_menu/core/network/sse/sse_message.dart';
import 'package:restauran_menu/core/network/sse/sse_transport_native.dart';

/// Regresi: transport native (dio + dart:io) harus men-streaming event
/// `text/event-stream` apa adanya, bukan menunggu response selesai.
void main() {
  test('DioSseTransport streams events as the server flushes them', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requestSub = server.listen((request) async {
      final response = request.response;
      response.statusCode = 200;
      response.headers.set('content-type', 'text/event-stream');
      response.headers.set('cache-control', 'no-cache');
      response.bufferOutput = false;

      response.add(
        utf8.encode('event: order.created\ndata: {"orderNumber":"#0001"}\n\n'),
      );
      await response.flush();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      response.add(
        utf8.encode('event: order.created\ndata: {"orderNumber":"#0002"}\n\n'),
      );
      await response.flush();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await response.close();
    });

    final transport = DioSseTransport(
      baseUrl: 'http://127.0.0.1:${server.port}',
    );
    final events = <SseEvent>[];

    final sub = transport
        .connect(
          const SseConfig(path: '/api/notifications/orders/stream?token=test'),
        )
        .listen(events.add);

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    await transport.disconnect();
    await sub.cancel();
    await requestSub.cancel();
    await server.close(force: true);

    final messages = events
        .where((e) => e.type == SseEventType.message)
        .map((e) => e.message!)
        .toList();

    expect(events.any((e) => e.type == SseEventType.open), isTrue);
    expect(events.any((e) => e.type == SseEventType.error), isFalse);
    expect(messages.map((m) => m.data), <String>[
      '{"orderNumber":"#0001"}',
      '{"orderNumber":"#0002"}',
    ]);
  });
}
