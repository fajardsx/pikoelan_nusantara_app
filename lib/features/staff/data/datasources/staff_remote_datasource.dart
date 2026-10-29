import '../../../../core/configs/api_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../models/invite_staff_payload.dart';
import '../models/staff_list_response.dart';
import '../models/staff_response.dart';

abstract class StaffRemoteDataSource {
  Future<StaffListResponse> getStaff({bool forceRefresh = false});
  Future<StaffResponse> inviteStaff(InviteStaffPayload payload);
  Future<bool> deleteStaff(int id);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  @override
  Future<StaffListResponse> getStaff({bool forceRefresh = false}) async {
    final res = await DioClient.instance.get(
      ApiKeys.users,
      forceRefresh: forceRefresh,
    );
    return StaffListResponse.fromJson(res.data);
  }

  @override
  Future<StaffResponse> inviteStaff(InviteStaffPayload payload) async {
    final res = await DioClient.instance.post(
      ApiKeys.inviteStaff,
      data: payload.toJson(),
    );
    return StaffResponse.fromJson(res.data);
  }

  @override
  Future<bool> deleteStaff(int id) async {
    await DioClient.instance.delete(ApiKeys.deleteStaff(id));
    return true;
  }
}
