import 'package:flutter/foundation.dart';
import 'package:restauran_menu/features/promos/data/models/promo_payload.dart';
import 'package:restauran_menu/features/promos/data/models/promo_stats_response.dart';

import '../../domain/entities/promo_entity.dart';
import '../../domain/usecases/create_promo_usecase.dart';
import '../../domain/usecases/delete_promo_usecase.dart';
import '../../domain/usecases/get_promo_stats_usecase.dart';
import '../../domain/usecases/get_promos_usecase.dart';
import '../../domain/usecases/toggle_promo_status_usecase.dart';
import '../../domain/usecases/update_promo_usecase.dart';
import '../../domain/usecases/validate_promo_usecase.dart';

enum PromoStatus { initial, loading, loaded, error }

class PromoProvider extends ChangeNotifier {
  final GetPromosUsecase getPromosUsecase;
  final CreatePromoUsecase createPromoUsecase;
  final UpdatePromoUsecase updatePromoUsecase;
  final DeletePromoUsecase deletePromoUsecase;
  final TogglePromoStatusUsecase togglePromoStatusUsecase;
  final GetPromoStatsUsecase getPromoStatsUsecase;
  final ValidatePromoUsecase validatePromoUsecase;

  PromoProvider(
    this.getPromosUsecase,
    this.createPromoUsecase,
    this.updatePromoUsecase,
    this.deletePromoUsecase,
    this.togglePromoStatusUsecase,
    this.getPromoStatsUsecase,
    this.validatePromoUsecase,
  );

  PromoStatus status = PromoStatus.initial;
  String? errorMessage;
  List<PromoEntity> promos = [];
  PromoStatsResponse? stats;

  Future<void> load({bool refresh = false}) async {
    status = PromoStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      promos = await getPromosUsecase(refresh: refresh);
      try {
        stats = await getPromoStatsUsecase();
      } catch (_) {
        // Fallback: stats API is optional / non-blocking
      }
      status = PromoStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = PromoStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addPromo(PromoPayload payload) async {
    try {
      await createPromoUsecase(payload);
      await load(refresh: true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> editPromo(int id, PromoPayload payload) async {
    try {
      await updatePromoUsecase(id, payload);
      await load(refresh: true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> removePromo(int id) async {
    try {
      await deletePromoUsecase(id);
      await load(refresh: true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> toggleStatus(int id) async {
    try {
      await togglePromoStatusUsecase(id);
      await load(refresh: true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> validate(String code, double amount, {int? memberId}) async {
    try {
      await validatePromoUsecase(
        code: code,
        orderAmount: amount,
        memberId: memberId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void refresh() async {
    await load(refresh: true);
  }
}
