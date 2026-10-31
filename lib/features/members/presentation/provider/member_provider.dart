import 'package:flutter/foundation.dart';
import 'package:restauran_menu/features/members/data/models/member_payload.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/create_member_usecase.dart';
import '../../domain/usecases/delete_member_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';
import '../../domain/usecases/update_member_usecase.dart';

enum MemberStatus { initial, loading, loaded, error }

class MemberProvider extends ChangeNotifier {
  final GetMembersUsecase getMembersUsecase;
  final CreateMemberUsecase createMemberUsecase;
  final UpdateMemberUsecase updateMemberUsecase;
  final DeleteMemberUsecase deleteMemberUsecase;

  MemberProvider(
    this.getMembersUsecase,
    this.createMemberUsecase,
    this.updateMemberUsecase,
    this.deleteMemberUsecase,
  );

  MemberStatus status = MemberStatus.initial;
  String? errorMessage;
  List<MemberEntity> members = [];

  Future<void> load({bool refresh = false}) async {
    status = MemberStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      members = await getMembersUsecase(refresh: refresh);
      status = MemberStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = MemberStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addMember(MemberPayload payload) async {
    try {
      await createMemberUsecase(payload);
      await load(refresh: true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> editMember(int id, MemberPayload payload) async {
    try {
      await updateMemberUsecase(id, payload);
      await load(refresh: true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> removeMember(int id) async {
    try {
      await deleteMemberUsecase(id);
      await load(refresh: true);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  void refresh() async {
    await load(refresh: true);
  }
}
