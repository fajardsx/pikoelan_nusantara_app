import 'package:restauran_menu/features/promos/data/models/validate_promo_response.dart';

import '../../domain/repositories/promo_repository.dart';

class ValidatePromoUsecase {
  final PromoRepository repository;
  const ValidatePromoUsecase(this.repository);

  Future<ValidatePromoResponse> call({
    required String code,
    required double orderAmount,
    int? memberId,
  }) => repository.validatePromo(
    code: code,
    orderAmount: orderAmount,
    memberId: memberId,
  );
}
