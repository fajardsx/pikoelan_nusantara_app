import '../repositories/auth_repositories.dart';

import '../entities/user_entities.dart';

class CheckAuthUsecase {
  final AuthRepository repository;

  CheckAuthUsecase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}
