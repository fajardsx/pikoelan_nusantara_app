import 'package:restauran_menu/features/promos/data/models/promo_payload.dart';
import 'package:restauran_menu/features/promos/data/models/promo_stats_response.dart';
import 'package:restauran_menu/features/promos/data/models/validate_promo_response.dart';
import 'package:restauran_menu/features/promos/domain/entities/promo_entity.dart';

abstract class PromoRepository {
  Future<List<PromoEntity>> getPromos({bool refresh});
  Future<PromoEntity?> createPromo(PromoPayload payload);
  Future<PromoEntity?> updatePromo(int id, PromoPayload payload);
  Future<void> deletePromo(int id);
  Future<PromoEntity?> togglePromoStatus(int id);
  Future<PromoStatsResponse> getPromoStats();
  Future<ValidatePromoResponse> validatePromo({
    required String code,
    required double orderAmount,
    int? memberId,
  });
}
