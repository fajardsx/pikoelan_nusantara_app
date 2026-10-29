import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? tenantId;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.tenantId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
      tenantId: json['tenantId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'tenantId': tenantId,
    };
  }

  String get roleLabel {
    switch (role) {
      case 'owner':
        return 'Pemilik';
      case 'manager':
        return 'Manajer';
      case 'kasir':
        return 'Kasir';
      case 'waiter':
        return 'Pelayan';
      case 'kitchen':
        return 'Dapur';
      case 'superadmin':
        return 'Superadmin';
      default:
        return 'Staf';
    }
  }

  bool get canManage => role == 'owner' || role == 'manager';

  @override
  List<Object?> get props => [id, name, email, role, tenantId];
}
