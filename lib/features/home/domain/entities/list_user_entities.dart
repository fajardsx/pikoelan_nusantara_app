import '../../../auth/domain/entities/user_entities.dart';

class ListUserEntity {
  final List<User> users;
  final int total;

  ListUserEntity({required this.users, required this.total});

  factory ListUserEntity.fromJson(Map<String, dynamic> json) {
    return ListUserEntity(
      users: json['users'] != null
          ? (json['users'] as List).map(((usr) => User.fromJson(usr))).toList()
          : [],
      total: json['total'] as int,
    );
  }
}
