import 'sse_message.dart';

/// Kontrak transport SSE lintas platform.
///
/// Implementasi native memakai Dio (`responseType: stream`), sedangkan web
/// memakai `fetch` + `ReadableStream` karena adapter XHR bawaan Dio menahan
/// body sampai response selesai.
abstract interface class SseTransport {
  /// Membuka koneksi dan otomatis reconnect dengan exponential backoff.
  Stream<SseEvent> connect(SseConfig config);

  /// Menutup koneksi aktif dan menghentikan loop reconnect.
  Future<void> disconnect();
}
