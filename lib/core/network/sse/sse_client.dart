import 'dart:async';

import 'package:dio/dio.dart';

import 'sse_message.dart';
import 'sse_parser.dart';
import 'sse_transport.dart';
import 'sse_transport_factory.dart';

export 'sse_message.dart';

/// Client Server-Sent Events lintas platform.
///
/// Transport dipilih otomatis:
/// - Android/iOS/desktop: stream Dio (`responseType: stream`).
/// - Web: `fetch` + `ReadableStream` karena adapter XHR milik Dio menahan body
///   sampai request selesai.
///
/// Keduanya memakai parser, backoff reconnect, dan aturan status fatal yang
/// sama (`decodeSseBytes`, `sseRetryDelay`, `isFatalSseStatus`).
class SseClient {
  SseClient({Dio? dio, String? baseUrl})
    : _transport = createSseTransport(dio: dio, baseUrl: baseUrl);

  final SseTransport _transport;

  /// Membuka koneksi SSE dan otomatis reconnect dengan exponential backoff.
  ///
  /// Stream ditutup ketika [disconnect] dipanggil, ketika server menutup
  /// koneksi tanpa retry, atau ketika status HTTP fatal (400/401/403/404).
  Stream<SseEvent> connect(SseConfig config) => _transport.connect(config);

  /// Menutup koneksi aktif dan menghentikan loop reconnect.
  Future<void> disconnect() => _transport.disconnect();

  /// Mem-parsing byte stream `text/event-stream` menjadi [SseMessage].
  ///
  /// Dipertahankan agar pemanggil lama dan unit test tetap berjalan.
  static Stream<SseMessage> decode(Stream<List<int>> bytes) =>
      decodeSseBytes(bytes);
}
