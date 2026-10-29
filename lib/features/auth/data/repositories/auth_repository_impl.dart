import 'package:restauran_menu/features/auth/data/datasources/auth_local_datasource.dart';

import '../../domain/entities/user_entities.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repositories.dart';
import '../models/login_payload.dart';
import '../models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDatasource localDS;

  AuthRepositoryImpl(this.remoteDataSource, this.localDS);

  @override
  Future<void> logout() async {
    await localDS.userLogout();
  }

  @override
  Future<LoginResponse> login(LoginPayload payload) async {
    final res = await remoteDataSource.login(payload);
    await localDS.saveToken(res.data!.token!);
    await localDS.saveUser(res.data!.user!);
    return res;
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await localDS.getToken();
    if (token == null) {
      return null;
    }
    await localDS.saveToken(token);
    return await localDS.getSaveUser();
  }

  @override
  Future<String?> getToken() async {
    return await localDS.getToken();
  }

  @override
  Future<User?> getDetailUser() async {
    final res = await remoteDataSource.myProfile();
    await localDS.saveUser(res.data!.user!);
    return res.data!.user;
  }
}
