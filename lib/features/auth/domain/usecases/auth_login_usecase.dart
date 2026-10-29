import '../../data/models/login_payload.dart';
import '../../data/models/login_response.dart';
import '../repositories/auth_repositories.dart';

class AuthLoginUsecase {
  final AuthRepository repository;

  AuthLoginUsecase(this.repository);

  Future<LoginResponse> call(LoginPayload payload) async {
    return repository.login(payload);
  }
}
