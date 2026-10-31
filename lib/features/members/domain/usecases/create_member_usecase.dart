import 'package:restauran_menu/features/members/data/models/member_payload.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/member_repository.dart';

class CreateMemberUsecase {
  final MemberRepository repository;
  const CreateMemberUsecase(this.repository);

  Future<MemberEntity?> call(MemberPayload payload) =>
      repository.createMember(payload);
}
