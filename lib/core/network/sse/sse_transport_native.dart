import 'dart:async';

import 'package:dio/dio.dart';

import 'sse_message.dart';
import 'sse_parser.dart';
import 'sse_transport.dart';

/// Membuat transport SSE sesuai platform yang sedang dikompilasi.
///
/// `sse_transport_factory.dart` memilih implementasi ini untuk Android, iOS,
/// desktop, dan unit test (VM).
SseTransport createSseTransport({Dio? dio, String? baseUrl}) =>
    DioSseTransport(dio: dio, baseUrl: baseUrl);

/// Transport SSE berbasis stream Dio untuk platform native.
class DioSseTransport implements SseTransport {
  DioSseTransport({Dio? dio, String? baseUrl, bool insecure = false})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl ?? ''));

  final Dio _dio;
  CancelToken? _cancelToken;
  int _generation = 0;

  @override
  Stream<SseEvent> connect(SseConfig config) async* {
    final generation = ++_generation;
    var attempt = 0;

    while (generation == _generation) {
      final cancelToken = CancelToken();
      _cancelToken = cancelToken;

      try {
        final response = await _dio.get<ResponseBody>(
          config.path,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.stream,
            // Duration.zero = tanpa timeout (koneksi SSE berumur panjang).
            receiveTimeout: Duration.zero,
            sendTimeout: Duration.zero,
            headers: <String, dynamic>{
              'Accept': 'text/event-stream',
              'Cache-Control': 'no-cache',
              ...config.headers,
            },
          ),
        );

        final body = response.data;
        if (body == null) {
          yield SseEvent.error(error: StateError('SSE response tanpa body.'));
        } else {
          attempt = 0;
          yield SseEvent.open();

          await for (final message in decodeSseBytes(body.stream)) {
            if (generation != _generation) return;
            yield SseEvent.message(message);
          }
        }
      } on DioException catch (e) {
        if (CancelToken.isCancel(e) || generation != _generation) return;

        final statusCode = e.response?.statusCode;
        yield SseEvent.error(error: e, statusCode: statusCode);

        if (isFatalSseStatus(statusCode)) {
          yield SseEvent.closed(reason: 'HTTP $statusCode');
          return;
        }
      } catch (e) {
        if (generation != _generation) return;
        yield SseEvent.error(error: e);
      } finally {
        if (identical(_cancelToken, cancelToken)) _cancelToken = null;
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
    final token = _cancelToken;
    _cancelToken = null;
    if (token != null && !token.isCancelled) {
      token.cancel('SSE disconnected');
    }
  }
}
