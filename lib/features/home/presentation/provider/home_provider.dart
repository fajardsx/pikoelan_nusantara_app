import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:restauran_menu/core/services/app_log.dart';
import 'package:restauran_menu/features/auth/domain/entities/user_entities.dart';
import 'package:restauran_menu/features/home/domain/usecases/get_all_users_usecase.dart';

enum HomeStatus { idle, loading, success, failure }

class HomeProvider extends ChangeNotifier {
  final GetAllUsersUsecase _getAllUsersUsecase;

  HomeProvider(this._getAllUsersUsecase);

  HomeStatus status = HomeStatus.idle;
  List<User>? listUser;
  String? errorMessage;

  Future<void> onGetAllUser() async {
    try {
      status = HomeStatus.loading;
      notifyListeners();

      final result = await _getAllUsersUsecase();
      AppLog.instance.logInfo('onGetAllUser result ${result?.data}');

      if (result?.success == true) {
        listUser = result!.data!.users;
        status = HomeStatus.success;
      } else {
        status = HomeStatus.failure;
        errorMessage = 'Failed to load users';
      }
      notifyListeners();
    } on DioException catch (e, s) {
      AppLog.instance.logError('onGetAllUser failed', e, s);
      errorMessage = "onGetAllUser failed ${e.toString()}";
      status = HomeStatus.failure;
      notifyListeners();
    } catch (e, s) {
      AppLog.instance.logError('onGetAllUser failed', e, s);
    }
  }
}
