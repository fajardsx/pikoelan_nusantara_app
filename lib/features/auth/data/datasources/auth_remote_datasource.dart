import 'package:restauran_menu/core/configs/api_keys.dart';

import '../../../../core/network/dio_client.dart';
import '../models/login_payload.dart';
import '../models/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginPayload payload);
  Future<LoginResponse> myProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> login(LoginPayload payload) async {
    // Implement API call here
    final res = await DioClient.instance.post(
      ApiKeys.authLogin,
      data: payload.toJson(),
    );
    final response = LoginResponse.fromJson(res.data);
    return response;
  }

  @override
  Future<LoginResponse> myProfile() async {
    // Implement API call here
    final res = await DioClient.instance.get(ApiKeys.getMyProfile);
    final response = LoginResponse.fromJson(res.data);
    return response;
  }
}
