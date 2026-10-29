import '../../data/models/get_all_user_response.dart';

abstract class HomeRepositories {
  Future<GetAllUserResponse?> getAllUser();
}
