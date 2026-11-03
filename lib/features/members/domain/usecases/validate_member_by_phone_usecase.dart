import 'package:restauran_menu/features/members/data/models/validate_member_response.dart';

import '../../domain/repositories/member_repository.dart';

class ValidateMemberByPhoneUsecase {
  final MemberRepository repository;
  const ValidateMemberByPhoneUsecase(this.repository);

  Future<ValidateMemberResponse> call(String phone) =>
      repository.validateMemberByPhone(phone);
}
