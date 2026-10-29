import 'package:restauran_menu/features/home/data/datasources/home_remote_datasource.dart';
import 'package:restauran_menu/features/home/domain/repositories/home_repositories.dart';

import '../models/get_all_user_response.dart';

class HomeRepositoriesImpl extends HomeRepositories {
  final HomeRemoteDatasource remote;

  HomeRepositoriesImpl(this.remote);

  @override
  Future<GetAllUserResponse?> getAllUser() async {
    final result = await remote.getAllUser();
    return result;
  }
}
