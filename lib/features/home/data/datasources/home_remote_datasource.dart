import '../../../../core/configs/api_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../models/get_all_user_response.dart';

abstract class HomeRemoteDatasource {
  Future<GetAllUserResponse> getAllUser();
}

class HomeRemoteDatasourceImpl extends HomeRemoteDatasource {
  @override
  Future<GetAllUserResponse> getAllUser() async {
    final res = await DioClient.instance.get(ApiKeys.getAllUser);
    GetAllUserResponse response = GetAllUserResponse.fromJson(res.data);
    return response;
  }
}
