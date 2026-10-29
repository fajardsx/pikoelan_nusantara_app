import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:restauran_menu/core/network/sse/sse_client.dart';
import 'package:restauran_menu/core/network/sse/sse_parser.dart';

void main() {
  group('SseClient.decode', () {
    test('parses frames across chunk boundaries', () async {
      final chunks = <List<int>>[
        utf8.encode('event: order.created\r\ndata: {"orderNumber":"#0001",'),
        utf8.encode('"status":"baru"}\r\n\r\n'),
        utf8.encode(': ping\n\n'),
        utf8.encode('data: halo\ndata: dunia\n\n'),
        utf8.encode('id: 7\nretry: 3000\ndata: tanpa-newline'),
      ];

      final messages = await SseClient.decode(
        Stream<List<int>>.fromIterable(chunks),
      ).toList();

      expect(messages, hasLength(4));

      expect(messages[0].event, 'order.created');
      expect(messages[0].data, '{"orderNumber":"#0001","status":"baru"}');

      expect(messages[1].event, 'heartbeat');
      expect(messages[1].data, 'ping');

      expect(messages[2].event, isNull);
      expect(messages[2].data, 'halo\ndunia');

      expect(messages[3].id, '7');
      expect(messages[3].retry, 3000);
      expect(messages[3].data, 'tanpa-newline');
    });

    test(
      'parses Uint8List chunks produced by the native dio transport',
      () async {
        // `ResponseBody.stream` milik dio bertipe Stream<Uint8List>. Sebelumnya
        // decoder UTF-8 gagal di runtime untuk tipe ini sehingga event SSE tidak
        // pernah sampai di Android/iOS/desktop.
        final chunks = Stream<Uint8List>.fromIterable(<Uint8List>[
          Uint8List.fromList(utf8.encode('event: order.created\n')),
          Uint8List.fromList(utf8.encode('data: {"orderNumber":"#0002"}\n\n')),
        ]);

        final messages = await decodeSseBytes(chunks).toList();

        expect(messages.single.event, 'order.created');
        expect(messages.single.data, '{"orderNumber":"#0002"}');
      },
    );

    test('decodes multibyte characters split across chunks', () async {
      final bytes = utf8.encode('data: café ☕\n\n');
      final split = bytes.length ~/ 2;

      final messages = await SseClient.decode(
        Stream<List<int>>.fromIterable([
          bytes.sublist(0, split),
          bytes.sublist(split),
        ]),
      ).toList();

      expect(messages.single.data, 'café ☕');
    });

    test('ignores empty frames and keeps data lines joined', () async {
      final messages = await SseClient.decode(
        Stream<List<int>>.fromIterable([utf8.encode('\n\n:heartbeat\n\n')]),
      ).toList();

      expect(messages, hasLength(1));
      expect(messages.single.event, 'heartbeat');
    });
  });
}
