import 'package:restauran_menu/features/promos/data/models/promo_payload.dart';

import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/promo_repository.dart';

class UpdatePromoUsecase {
  final PromoRepository repository;
  const UpdatePromoUsecase(this.repository);

  Future<PromoEntity?> call(int id, PromoPayload payload) =>
      repository.updatePromo(id, payload);
}
