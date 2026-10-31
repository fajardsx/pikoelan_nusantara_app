import 'package:restauran_menu/features/promos/data/models/promo_payload.dart';

import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/promo_repository.dart';

class CreatePromoUsecase {
  final PromoRepository repository;
  const CreatePromoUsecase(this.repository);

  Future<PromoEntity?> call(PromoPayload payload) =>
      repository.createPromo(payload);
}
