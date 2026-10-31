import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/promo_repository.dart';

class GetPromosUsecase {
  final PromoRepository repository;
  const GetPromosUsecase(this.repository);

  Future<List<PromoEntity>> call({bool refresh = false}) =>
      repository.getPromos(refresh: refresh);
}
