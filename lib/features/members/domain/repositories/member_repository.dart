import 'package:restauran_menu/features/members/data/models/member_payload.dart';
import 'package:restauran_menu/features/members/data/models/validate_member_response.dart';

import '../../domain/entities/member_entity.dart';

abstract class MemberRepository {
  Future<List<MemberEntity>> getMembers({bool refresh});
  Future<MemberEntity?> createMember(MemberPayload payload);
  Future<MemberEntity?> updateMember(int id, MemberPayload payload);
  Future<void> deleteMember(int id);
  Future<ValidateMemberResponse> validateMemberByPhone(String phone);
}
