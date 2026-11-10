import 'dart:convert';

import '../../../../core/network/sse/sse_client.dart';

/// Tahap transport yang dibawa satu [SseEvent].
enum OrderStreamTransport { open, message, error, reconnecting, closed }

/// Model data-layer untuk satu event SSE sebelum dipetakan ke domain.
class OrderStreamMessageModel {
  const OrderStreamMessageModel({
    required this.transport,
    this.event,
    this.payload,
    this.rawData,
    this.errorMessage,
    this.statusCode,
    this.attempt,
    this.retryDelay,
    this.reason,
  });

  factory OrderStreamMessageModel.fromSse(SseEvent event) {
    return OrderStreamMessageModel(
      transport: switch (event.type) {
        SseEventType.open => OrderStreamTransport.open,
        SseEventType.message => OrderStreamTransport.message,
        SseEventType.error => OrderStreamTransport.error,
        SseEventType.reconnecting => OrderStreamTransport.reconnecting,
        SseEventType.closed => OrderStreamTransport.closed,
      },
      event: event.message?.event,
      payload: _decodePayload(event.message?.data),
      rawData: event.message?.data,
      errorMessage: event.error?.toString(),
      statusCode: event.statusCode,
      attempt: event.attempt,
      retryDelay: event.retryDelay,
      reason: event.reason,
    );
  }

  final OrderStreamTransport transport;
  final String? event;
  final Map<String, dynamic>? payload;
  final String? rawData;
  final String? errorMessage;
  final int? statusCode;
  final int? attempt;
  final Duration? retryDelay;
  final String? reason;

  static Map<String, dynamic>? _decodePayload(String? data) {
    final raw = data?.trim();
    if (raw == null || raw.isEmpty) return null;
    // Jika bukan JSON (mis. heartbeat) langsung null.
    if (!raw.startsWith('{') && !raw.startsWith('[')) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'data': decoded};
    } on FormatException {
      // Payload bukan JSON valid.
      return null;
    }
  }
}
