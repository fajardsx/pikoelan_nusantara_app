import 'dart:convert';

import 'sse_message.dart';

/// Mem-parsing byte stream `text/event-stream` menjadi [SseMessage].
///
/// Dipisah dari koneksi supaya bisa dipakai bersama oleh transport native
/// (Dio) dan web (`fetch`), serta bisa dites tanpa jaringan.
Stream<SseMessage> decodeSseBytes(Stream<List<int>> bytes) async* {
  // Transport native (dio, `ResponseType.stream`) mengirim `Stream<Uint8List>`,
  // sedangkan `utf8.decoder` bertipe `StreamTransformer<List<int>, String>`.
  // `Stream.transform` melakukan cek kovarian saat runtime, sehingga untuk
  // Stream<Uint8List> decoder ditolak dengan error:
  //   type 'Utf8Decoder' is not a subtype of type
  //   'StreamTransformer<Uint8List, String>'
  // Normalisasi dulu ke `Stream<List<int>>` supaya aman di native maupun web.
  final byteStream = bytes.map<List<int>>((chunk) => chunk);
  final lines = byteStream
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  String? eventName;
  String? id;
  int? retry;
  var hasData = false;
  final data = StringBuffer();

  String payload() {
    final value = data.toString();
    return value.endsWith('\n') ? value.substring(0, value.length - 1) : value;
  }

  void reset() {
    eventName = null;
    id = null;
    retry = null;
    hasData = false;
    data.clear();
  }

  await for (final line in lines) {
    if (line.isEmpty) {
      if (hasData || eventName != null) {
        yield SseMessage(
          event: eventName,
          data: payload(),
          id: id,
          retry: retry,
        );
      }
      reset();
      continue;
    }

    // Baris komentar biasanya dipakai server sebagai heartbeat (`: ping`).
    if (line.startsWith(':')) {
      yield SseMessage(event: 'heartbeat', data: line.substring(1).trim());
      continue;
    }

    final separator = line.indexOf(':');
    final field = separator == -1 ? line : line.substring(0, separator);
    var value = separator == -1 ? '' : line.substring(separator + 1);
    if (value.startsWith(' ')) value = value.substring(1);

    switch (field) {
      case 'event':
        eventName = value;
      case 'data':
        data.write(value);
        data.write('\n');
        hasData = true;
      case 'id':
        id = value;
      case 'retry':
        retry = int.tryParse(value);
    }
  }

  // Server menutup koneksi tanpa baris kosong terakhir.
  if (hasData || eventName != null) {
    yield SseMessage(event: eventName, data: payload(), id: id, retry: retry);
  }
}

/// Status HTTP yang tidak masuk akal untuk direconnect (token salah, path
/// salah, atau request ditolak permanen).
bool isFatalSseStatus(int? statusCode) {
  if (statusCode == null) return false;
  return statusCode == 400 ||
      statusCode == 401 ||
      statusCode == 403 ||
      statusCode == 404;
}

/// Exponential backoff dengan batas atas [SseConfig.maxRetryDelay].
Duration sseRetryDelay(int attempt, SseConfig config) {
  final factor = config.retryFactor <= 0 ? 1 : config.retryFactor;
  var multiplier = 1;
  for (var i = 1; i < attempt && multiplier < 16; i++) {
    multiplier *= factor;
  }
  final millis = config.initialRetryDelay.inMilliseconds * multiplier;
  return Duration(
    milliseconds: millis
        .clamp(
          config.initialRetryDelay.inMilliseconds,
          config.maxRetryDelay.inMilliseconds,
        )
        .toInt(),
  );
}
