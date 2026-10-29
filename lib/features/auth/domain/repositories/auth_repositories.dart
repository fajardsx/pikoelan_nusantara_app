import '../../data/models/login_payload.dart';
import '../../data/models/login_response.dart';
import '../entities/user_entities.dart';

abstract class AuthRepository {
  Future<LoginResponse> login(LoginPayload payload);
  Future<void> logout();

  Future<User?> getDetailUser();
  Future<User?> getCurrentUser();

  Future<String?> getToken();
}
