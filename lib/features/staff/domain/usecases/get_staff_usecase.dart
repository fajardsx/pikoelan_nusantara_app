import '../entities/staff_entity.dart';
import '../repositories/staff_repositories.dart';

class GetStaffUsecase {
  final StaffRepository repository;
  const GetStaffUsecase(this.repository);

  Future<List<StaffEntity>> call({bool forceRefresh = false}) async =>
      repository.getStaff(forceRefresh: forceRefresh);
}
