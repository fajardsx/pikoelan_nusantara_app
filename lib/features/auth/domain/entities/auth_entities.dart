import 'user_entities.dart';

class AuthEntity {
  final User? user;
  final String? token;

  AuthEntity({required this.user, required this.token});

  factory AuthEntity.fromJson(Map<String, dynamic> json) {
    return AuthEntity(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'] != null ? json['token'] as String : null,
    );
  }
}
