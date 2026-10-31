import 'package:restauran_menu/features/promos/domain/entities/promo_entity.dart';

import '../../domain/repositories/promo_repository.dart';

class TogglePromoStatusUsecase {
  final PromoRepository repository;
  const TogglePromoStatusUsecase(this.repository);

  Future<PromoEntity?> call(int id) => repository.togglePromoStatus(id);
}
