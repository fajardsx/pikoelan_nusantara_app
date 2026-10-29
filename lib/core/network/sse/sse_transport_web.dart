import 'dart:async';
import 'dart:js_interop';

import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

import 'sse_message.dart';
import 'sse_parser.dart';
import 'sse_transport.dart';

/// Membuat transport SSE versi web (dipilih oleh `sse_transport_factory.dart`).
///
/// `dio` tidak dipakai di web karena adapter XHR milik Dio menahan body sampai
/// request selesai, sehingga event tidak pernah sampai secara realtime.
SseTransport createSseTransport({Dio? dio, String? baseUrl}) =>
    FetchSseTransport(baseUrl: baseUrl);

/// Transport SSE khusus browser.
///
/// Memakai `fetch` + `ReadableStream` (bukan `EventSource`) supaya:
/// - event bernama (`order.created`, `order.status_updated`, dst.) tetap
///   terbaca tanpa perlu mendaftar nama event satu per satu;
/// - header `Authorization` bisa dikirim;
/// - status HTTP (401/403/404) bisa dibaca sehingga token yang salah tidak
///   membuat browser reconnect terus-menerus.
///
/// Backend tetap harus mengirim header CORS yang mengizinkan origin aplikasi.
class FetchSseTransport implements SseTransport {
  FetchSseTransport({String? baseUrl}) : _baseUrl = baseUrl ?? '';

  final String _baseUrl;
  web.AbortController? _abortController;
  int _generation = 0;

  @override
  Stream<SseEvent> connect(SseConfig config) async* {
    final generation = ++_generation;
    final url = _resolveUrl(config.path);
    var attempt = 0;

    while (generation == _generation) {
      final abort = web.AbortController();
      _abortController = abort;

      try {
        final headers = web.Headers();
        headers.set('Accept', 'text/event-stream');
        headers.set('Cache-Control', 'no-cache');
        for (final entry in config.headers.entries) {
          headers.set(entry.key, entry.value);
        }

        final response = await web.window
            .fetch(
              url.toString().toJS,
              web.RequestInit(
                method: 'GET',
                headers: headers,
                cache: 'no-store',
                signal: abort.signal,
              ),
            )
            .toDart;

        if (generation != _generation) return;

        final status = response.status;
        if (!response.ok) {
          yield SseEvent.error(statusCode: status);
          if (isFatalSseStatus(status)) {
            yield SseEvent.closed(reason: 'HTTP $status');
            return;
          }
        } else {
          final body = response.body;
          if (body == null) {
            yield SseEvent.error(error: StateError('SSE response tanpa body.'));
          } else {
            attempt = 0;
            yield SseEvent.open();

            await for (final message in decodeSseBytes(
              _readBytes(body, generation),
            )) {
              if (generation != _generation) return;
              yield SseEvent.message(message);
            }
          }
        }
      } catch (e) {
        // Abort dari disconnect() bukan error yang perlu dilaporkan.
        if (generation != _generation) return;
        yield SseEvent.error(error: e);
      } finally {
        if (identical(_abortController, abort)) _abortController = null;
      }

      if (generation != _generation) return;

      attempt++;
      final maxAttempts = config.maxAttempts;
      if (maxAttempts != null && attempt > maxAttempts) {
        yield SseEvent.closed(reason: 'Batas reconnect tercapai.');
        return;
      }

      final delay = sseRetryDelay(attempt, config);
      yield SseEvent.reconnecting(attempt: attempt, retryDelay: delay);
      await Future<void>.delayed(delay);
    }
  }

  @override
  Future<void> disconnect() async {
    _generation++;
    final abort = _abortController;
    _abortController = null;
    abort?.abort();
  }

  Stream<List<int>> _readBytes(web.ReadableStream body, int generation) async* {
    final reader = body.getReader() as web.ReadableStreamDefaultReader;
    try {
      while (generation == _generation) {
        final result = await reader.read().toDart;
        if (result.done) return;

        final value = result.value;
        if (value == null) continue;

        yield (value as JSUint8Array).toDart;
      }
    } finally {
      reader.releaseLock();
    }
  }

  Uri _resolveUrl(String path) {
    final parsed = Uri.tryParse(path);
    if (parsed != null && parsed.hasScheme) return parsed;

    var base = _baseUrl;
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    final suffix = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$suffix');
  }
}
