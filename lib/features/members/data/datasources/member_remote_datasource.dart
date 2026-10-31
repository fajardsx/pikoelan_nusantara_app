import 'package:restauran_menu/core/configs/api_keys.dart';
import 'package:restauran_menu/core/network/dio_client.dart';
import 'package:restauran_menu/features/members/data/models/member_payload.dart';

import '../models/member_response.dart';

abstract class MemberRemoteDataSource {
  Future<MemberResponse> getMembers(bool refresh);
  Future<MemberResponse> createMember(MemberPayload payload);
  Future<MemberResponse> updateMember(int id, MemberPayload payload);
  Future<void> deleteMember(int id);
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  @override
  Future<MemberResponse> getMembers(bool refresh) async {
    final res = await DioClient.instance.get(
      ApiKeys.member,
      forceRefresh: refresh,
    );
    return MemberResponse.fromJson(res.data);
  }

  @override
  Future<MemberResponse> createMember(MemberPayload payload) async {
    final res = await DioClient.instance.post(
      ApiKeys.member,
      data: payload.toJson(),
    );
    return MemberResponse.fromJson(res.data);
  }

  @override
  Future<MemberResponse> updateMember(int id, MemberPayload payload) async {
    final res = await DioClient.instance.put(
      ApiKeys.memberById(id.toString()),
      data: payload.toJson(),
    );
    return MemberResponse.fromJson(res.data);
  }

  @override
  Future<void> deleteMember(int id) async {
    await DioClient.instance.delete(ApiKeys.memberById(id.toString()));
  }
}
