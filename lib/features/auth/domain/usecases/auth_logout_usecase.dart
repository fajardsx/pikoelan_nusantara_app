import '../repositories/auth_repositories.dart';

class AuthLogoutUsecase {
  final AuthRepository repository;

  AuthLogoutUsecase(this.repository);

  Future<void> call() async {
    return repository.logout();
  }
}
