import 'package:restauran_menu/features/members/data/models/member_payload.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/member_repository.dart';

class UpdateMemberUsecase {
  final MemberRepository repository;
  const UpdateMemberUsecase(this.repository);

  Future<MemberEntity?> call(int id, MemberPayload payload) =>
      repository.updateMember(id, payload);
}
