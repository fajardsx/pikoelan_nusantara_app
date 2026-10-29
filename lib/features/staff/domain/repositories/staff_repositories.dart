import '../../data/models/invite_staff_payload.dart';
import '../entities/staff_entity.dart';

abstract class StaffRepository {
  Future<List<StaffEntity>> getStaff({bool forceRefresh = false});
  Future<StaffEntity?> inviteStaff(InviteStaffPayload payload);
  Future<bool> deleteStaff(int id);
}
