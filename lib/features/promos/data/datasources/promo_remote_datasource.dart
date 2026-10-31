import 'package:restauran_menu/core/configs/api_keys.dart';
import 'package:restauran_menu/core/network/dio_client.dart';
import 'package:restauran_menu/features/promos/data/models/promo_stats_response.dart';
import 'package:restauran_menu/features/promos/data/models/validate_promo_response.dart';

import '../models/promo_payload.dart';
import '../models/promo_response.dart'; // assume similar to category_response

abstract class PromoRemoteDataSource {
  Future<PromoResponse> getPromos({bool refresh});
  Future<PromoResponse> createPromo(PromoPayload payload);
  Future<PromoResponse> updatePromo(int id, PromoPayload payload);
  Future<void> deletePromo(int id);
  Future<PromoResponse> togglePromoStatus(int id);
  Future<PromoStatsResponse> getPromoStats();
  Future<ValidatePromoResponse> validatePromo({
    required String code,
    required double orderAmount,
    int? memberId,
  });
}

class PromoRemoteDataSourceImpl implements PromoRemoteDataSource {
  @override
  Future<PromoResponse> getPromos({bool refresh = false}) async {
    final res = await DioClient.instance.get(
      ApiKeys.promos,
      forceRefresh: refresh,
    );
    return PromoResponse.fromJson(res.data);
  }

  @override
  Future<PromoResponse> createPromo(PromoPayload payload) async {
    final res = await DioClient.instance.post(
      ApiKeys.promos,
      data: payload.toJson(),
    );
    return PromoResponse.fromJson(res.data);
  }

  @override
  Future<PromoResponse> updatePromo(int id, PromoPayload payload) async {
    final res = await DioClient.instance.put(
      ApiKeys.promoById(id.toString()),
      data: payload.toJson(),
    );
    return PromoResponse.fromJson(res.data);
  }

  @override
  Future<void> deletePromo(int id) async {
    await DioClient.instance.delete(ApiKeys.promoById(id.toString()));
  }

  @override
  Future<PromoResponse> togglePromoStatus(int id) async {
    final res = await DioClient.instance.patch(
      ApiKeys.toggleStatusPromoById(id.toString()),
    );
    return PromoResponse.fromJson(res.data);
  }

  @override
  Future<PromoStatsResponse> getPromoStats() async {
    final res = await DioClient.instance.get(ApiKeys.statPromo);
    return PromoStatsResponse.fromJson(res.data);
  }

  @override
  Future<ValidatePromoResponse> validatePromo({
    required String code,
    required double orderAmount,
    int? memberId,
  }) async {
    final data = {
      'code': code,
      'orderAmount': orderAmount,
      'memberId': ?memberId,
    };
    final res = await DioClient.instance.post(
      ApiKeys.validatePromo,
      data: data,
    );
    return ValidatePromoResponse.fromJson(res.data);
  }
}
