import '../../domain/repositories/member_repository.dart';

class DeleteMemberUsecase {
  final MemberRepository repository;
  const DeleteMemberUsecase(this.repository);

  Future<void> call(int id) => repository.deleteMember(id);
}
