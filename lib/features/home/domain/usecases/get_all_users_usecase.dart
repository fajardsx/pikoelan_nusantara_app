import '../../data/models/get_all_user_response.dart';
import '../repositories/home_repositories.dart';

class GetAllUsersUsecase {
  final HomeRepositories homeRepositories;

  const GetAllUsersUsecase(this.homeRepositories);

  Future<GetAllUserResponse?> call() async {
    return await homeRepositories.getAllUser();
  }
}
