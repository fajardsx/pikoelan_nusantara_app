import '../../domain/repositories/promo_repository.dart';

class DeletePromoUsecase {
  final PromoRepository repository;
  const DeletePromoUsecase(this.repository);

  Future<void> call(int id) => repository.deletePromo(id);
}
