import 'package:equatable/equatable.dart';

class StaffEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  const StaffEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory StaffEntity.fromJson(Map<String, dynamic> json) {
    return StaffEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'staff',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static const _roleLabels = {
    'owner': 'Pemilik',
    'manager': 'Manajer',
    'kasir': 'Kasir',
    'waiters': 'Pelayan',
    'kitchen': 'Dapur',
  };

  String get roleLabel => _roleLabels[role] ?? 'Staf';

  @override
  List<Object?> get props => [id, name, email, role, createdAt];
}
