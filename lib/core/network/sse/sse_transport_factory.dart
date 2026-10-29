import 'package:dio/dio.dart';

import 'sse_transport.dart';
import 'sse_transport_native.dart'
    if (dart.library.js_interop) 'sse_transport_web.dart' as impl;

/// Memilih implementasi transport SSE sesuai platform.
///
/// - Native (Android/iOS/desktop/VM): [DioSseTransport].
/// - Web: `FetchSseTransport` berbasis `fetch` + `ReadableStream`.
SseTransport createSseTransport({Dio? dio, String? baseUrl}) =>
    impl.createSseTransport(dio: dio, baseUrl: baseUrl);
