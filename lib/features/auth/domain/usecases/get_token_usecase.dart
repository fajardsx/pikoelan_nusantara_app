import '../repositories/auth_repositories.dart';

class GetTokenUsecase {
  final AuthRepository repository;

  GetTokenUsecase(this.repository);

  Future<String?> call() async {
    return repository.getToken();
  }
}
