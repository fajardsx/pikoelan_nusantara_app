import '../../data/models/invite_staff_payload.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_repositories.dart';

class InviteStaffUsecase {
  final StaffRepository repository;
  const InviteStaffUsecase(this.repository);

  Future<StaffEntity?> call(InviteStaffPayload payload) async => repository.inviteStaff(payload);
}
