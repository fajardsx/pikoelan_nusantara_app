/// Jenis event transport SSE (bukan event bisnis).
enum SseEventType { open, message, error, reconnecting, closed }

/// Satu frame SSE yang sudah diparse (`event:`, `data:`, `id:`, `retry:`).
class SseMessage {
  const SseMessage({required this.data, this.event, this.id, this.retry});

  final String data;
  final String? event;
  final String? id;
  final int? retry;

  bool get isHeartbeat {
    final name = (event ?? '').toLowerCase();
    return name == 'ping' || name == 'heartbeat' || name == 'keepalive';
  }

  @override
  String toString() => 'SseMessage(event: $event, data: $data)';
}

/// Event dari `SseClient.connect` yang membawa status koneksi + payload.
class SseEvent {
  SseEvent._({
    required this.type,
    this.message,
    this.error,
    this.statusCode,
    this.attempt,
    this.retryDelay,
    this.reason,
  });

  factory SseEvent.open() => SseEvent._(type: SseEventType.open);

  factory SseEvent.message(SseMessage message) =>
      SseEvent._(type: SseEventType.message, message: message);

  factory SseEvent.error({Object? error, int? statusCode}) => SseEvent._(
    type: SseEventType.error,
    error: error,
    statusCode: statusCode,
  );

  factory SseEvent.reconnecting({
    required int attempt,
    required Duration retryDelay,
  }) => SseEvent._(
    type: SseEventType.reconnecting,
    attempt: attempt,
    retryDelay: retryDelay,
  );

  factory SseEvent.closed({String? reason}) =>
      SseEvent._(type: SseEventType.closed, reason: reason);

  final SseEventType type;
  final SseMessage? message;
  final Object? error;
  final int? statusCode;
  final int? attempt;
  final Duration? retryDelay;
  final String? reason;
}

/// Konfigurasi satu koneksi SSE.
class SseConfig {
  const SseConfig({
    required this.path,
    this.headers = const <String, String>{},
    this.initialRetryDelay = const Duration(seconds: 2),
    this.maxRetryDelay = const Duration(seconds: 30),
    this.retryFactor = 2,
    this.maxAttempts,
  });

  /// Path relatif terhadap `baseUrl` (boleh juga URL absolut).
  final String path;
  final Map<String, String> headers;
  final Duration initialRetryDelay;
  final Duration maxRetryDelay;
  final int retryFactor;

  /// `null` = retry tanpa batas sampai `SseClient.disconnect` dipanggil.
  final int? maxAttempts;
}
