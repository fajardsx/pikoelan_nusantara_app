import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repositories.dart';
import '../datasources/staff_remote_datasource.dart';
import '../models/invite_staff_payload.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;
  StaffRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StaffEntity>> getStaff({bool forceRefresh = false}) async {
    final res = await remoteDataSource.getStaff(forceRefresh: forceRefresh);
    return res.data ?? [];
  }

  @override
  Future<StaffEntity?> inviteStaff(InviteStaffPayload payload) async {
    final res = await remoteDataSource.inviteStaff(payload);
    return res.data;
  }

  @override
  Future<bool> deleteStaff(int id) async {
    final res = await remoteDataSource.deleteStaff(id);
    return res;
  }
}
