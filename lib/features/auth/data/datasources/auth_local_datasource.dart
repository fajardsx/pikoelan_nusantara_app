import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entities.dart';

abstract class AuthLocalDatasource {
  final DioClient dioClient;
  AuthLocalDatasource({required this.dioClient});

  Future<void> saveUser(User user);
  Future<User?> getSaveUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> userLogout();
}

class AuthLocalDatasourceImpl extends AuthLocalDatasource {
  final prefs = SharedPreferences.getInstance();

  AuthLocalDatasourceImpl({required super.dioClient});

  @override
  Future<void> saveUser(User user) async {
    final p = await prefs;
    await p.setString('user', jsonEncode(user.toJson()));
  }

  @override
  Future<User?> getSaveUser() async {
    final p = await prefs;
    if (p.getString('user') != null) {
      var userstring = p.getString('user');
      final user = User.fromJson(jsonDecode(userstring!));
      return user;
    } else {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    final p = await prefs;
    dioClient.saveToken(token);
    await p.setString('token', token);
  }

  @override
  Future<String?> getToken() async {
    final p = await prefs;
    return p.getString('token');
  }

  @override
  Future<void> clearToken() async {
    final p = await prefs;
    dioClient.cleanToken();
    await p.remove('token');
  }

  @override
  Future<void> userLogout() async {
    final p = await prefs;
    unawaited(clearToken());
    unawaited(p.remove('user'));
  }
}
