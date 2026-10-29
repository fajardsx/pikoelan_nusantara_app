import '../../../auth/domain/usecases/get_token_usecase.dart';
import '../entities/order_stream_event.dart';
import '../repositories/order_stream_repository.dart';

/// Membuka stream order realtime memakai JWT yang tersimpan di local storage.
///
/// Token dibaca ulang setiap kali [call] dieksekusi sehingga restart stream
/// setelah login ulang selalu memakai token terbaru.
class WatchOrderStreamUsecase {
  const WatchOrderStreamUsecase(this._repository, this._getTokenUsecase);

  final OrderStreamRepository _repository;
  final GetTokenUsecase _getTokenUsecase;

  Stream<OrderStreamEvent> call() async* {
    final token = await _getTokenUsecase();
    if (token == null || token.trim().isEmpty) {
      throw StateError('Sesi login tidak ditemukan. Silakan login ulang.');
    }
    yield* _repository.watchOrders(jwt: token.trim());
  }

  Future<void> disconnect() => _repository.disconnect();
}
