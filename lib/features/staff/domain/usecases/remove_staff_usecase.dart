import '../../domain/repositories/staff_repositories.dart';

class DeleteStaffUsecase {
  final StaffRepository repository;
  const DeleteStaffUsecase(this.repository);

  Future<bool> call(int id) => repository.deleteStaff(id);
}
