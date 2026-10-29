import 'package:hive_ce/hive.dart';

part 'user_hive.g.dart';

@HiveType(typeId: 1)
class UserHive {
  @HiveField(0)
  final int userId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String role;
  @HiveField(4)
  final String? profilePictureUrl;
  @HiveField(5)
  final String dateCreated;

  UserHive({
    required this.dateCreated,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.profilePictureUrl,
  });
}
