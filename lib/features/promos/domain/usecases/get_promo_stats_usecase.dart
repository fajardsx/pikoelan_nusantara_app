import 'package:restauran_menu/features/promos/data/models/promo_stats_response.dart';

import '../../domain/repositories/promo_repository.dart';

class GetPromoStatsUsecase {
  final PromoRepository repository;
  const GetPromoStatsUsecase(this.repository);

  Future<PromoStatsResponse> call() => repository.getPromoStats();
}
