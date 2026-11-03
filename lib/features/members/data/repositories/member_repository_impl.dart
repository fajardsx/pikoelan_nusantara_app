import 'package:restauran_menu/features/members/data/models/member_payload.dart';
import 'package:restauran_menu/features/members/data/models/validate_member_response.dart';

import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/member_remote_datasource.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource remoteDataSource;
  MemberRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MemberEntity>> getMembers({bool refresh = false}) async {
    final res = await remoteDataSource.getMembers(refresh);
    if (res.items.isNotEmpty) {
      return res.items;
    }
    return res.data != null ? [res.data!] : [];
  }

  @override
  Future<MemberEntity?> createMember(MemberPayload payload) async {
    final res = await remoteDataSource.createMember(payload);
    return res.data;
  }

  @override
  Future<MemberEntity?> updateMember(int id, MemberPayload payload) async {
    final res = await remoteDataSource.updateMember(id, payload);
    return res.data;
  }

  @override
  Future<void> deleteMember(int id) async {
    await remoteDataSource.deleteMember(id);
  }

  @override
  Future<ValidateMemberResponse> validateMemberByPhone(String phone) async {
    final res = await remoteDataSource.validateMemberByPhone(phone);
    return res;
  }
}
