import 'package:flutter/foundation.dart';
import 'package:restauran_menu/features/staff/domain/usecases/remove_staff_usecase.dart';

import '../../data/models/invite_staff_payload.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/get_staff_usecase.dart';
import '../../domain/usecases/invite_staff_usecase.dart';

enum StaffStatus { initial, loading, loaded, error }

enum InviteStatus { idle, submitting, success, error }

class StaffProvider extends ChangeNotifier {
  final GetStaffUsecase getStaffUsecase;
  final InviteStaffUsecase inviteStaffUsecase;
  final DeleteStaffUsecase deleteStaffUsecase;

  StaffProvider(
    this.getStaffUsecase,
    this.inviteStaffUsecase,
    this.deleteStaffUsecase,
  );

  StaffStatus status = StaffStatus.initial;
  List<StaffEntity> staff = [];
  String? errorMessage;

  InviteStatus inviteStatus = InviteStatus.idle;
  String? inviteError;

  Future<void> load({bool forceRefresh = false}) async {
    status = StaffStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      staff = await getStaffUsecase(forceRefresh: forceRefresh);
      status = StaffStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = StaffStatus.error;
    }
    notifyListeners();
  }

  Future<bool> invite({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    inviteStatus = InviteStatus.submitting;
    notifyListeners();
    try {
      await inviteStaffUsecase(
        InviteStaffPayload(
          name: name,
          email: email,
          password: password,
          role: role,
        ),
      );
      inviteStatus = InviteStatus.success;
      notifyListeners();
      await load(forceRefresh: true);
      return true;
    } catch (e) {
      inviteError = e.toString();
      inviteStatus = InviteStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStaff(int id) async {
    final res = await deleteStaffUsecase(id);
    if (res) {
      staff.removeWhere((s) => s.id == id);
      refresh();
    }
    return res;
  }

  Future<bool> updateStaff({
    required int id,
    required String name,
    required String role,
  }) async {
    try {
      final index = staff.indexWhere((s) => s.id == id);
      if (index != -1) {
        final old = staff[index];
        staff[index] = StaffEntity(
          id: old.id,
          name: name,
          email: old.email,
          role: role,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void resetInviteStatus() {
    inviteStatus = InviteStatus.idle;
    inviteError = null;
  }

  void refresh() async {
    await load(forceRefresh: true);
  }
}
