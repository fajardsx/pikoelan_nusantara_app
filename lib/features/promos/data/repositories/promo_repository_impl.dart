import 'package:restauran_menu/features/promos/data/models/promo_payload.dart';
import 'package:restauran_menu/features/promos/data/models/promo_stats_response.dart';
import 'package:restauran_menu/features/promos/data/models/validate_promo_response.dart';

import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/promo_repository.dart';
import '../datasources/promo_remote_datasource.dart';

class PromoRepositoryImpl implements PromoRepository {
  final PromoRemoteDataSource remoteDataSource;
  PromoRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PromoEntity>> getPromos({bool refresh = false}) async {
    final res = await remoteDataSource.getPromos(refresh: refresh);
    if (res.items.isNotEmpty) {
      return res.items;
    }
    return res.data != null ? [res.data!] : [];
  }

  @override
  Future<PromoEntity?> createPromo(PromoPayload payload) async {
    final res = await remoteDataSource.createPromo(payload);
    return res.data;
  }

  @override
  Future<PromoEntity?> updatePromo(int id, PromoPayload payload) async {
    final res = await remoteDataSource.updatePromo(id, payload);
    return res.data;
  }

  @override
  Future<void> deletePromo(int id) async {
    await remoteDataSource.deletePromo(id);
  }

  @override
  Future<PromoEntity?> togglePromoStatus(int id) async {
    final res = await remoteDataSource.togglePromoStatus(id);
    return res.data;
  }

  @override
  Future<PromoStatsResponse> getPromoStats() async {
    return await remoteDataSource.getPromoStats();
  }

  @override
  Future<ValidatePromoResponse> validatePromo({
    required String code,
    required double orderAmount,
    int? memberId,
  }) async {
    return await remoteDataSource.validatePromo(
      code: code,
      orderAmount: orderAmount,
      memberId: memberId,
    );
  }
}
