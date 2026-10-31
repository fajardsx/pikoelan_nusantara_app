import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/member_repository.dart';

class GetMembersUsecase {
  final MemberRepository repository;
  const GetMembersUsecase(this.repository);

  Future<List<MemberEntity>> call({bool refresh = false}) =>
      repository.getMembers(refresh: refresh);
}
