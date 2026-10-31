import 'package:equatable/equatable.dart';
import 'package:restauran_menu/core/common/common_utils.dart';

class MemberEntity extends Equatable {
  final int id;
  final int tenantId;
  final String memberCode;
  final String name;
  final String phone;
  final String? email;
  final String tier;
  final int points;
  final double totalSpent;
  final int totalVisits;
  final DateTime? birthDate;
  final DateTime joinDate;
  final String? address;
  final String? notes;
  final bool isActive;

  const MemberEntity({
    required this.id,
    required this.tenantId,
    required this.memberCode,
    required this.name,
    required this.phone,
    this.email,
    required this.tier,
    required this.points,
    required this.totalSpent,
    required this.totalVisits,
    this.birthDate,
    required this.joinDate,
    this.address,
    this.notes,
    required this.isActive,
  });

  factory MemberEntity.fromJson(Map<String, dynamic> json) {
    return MemberEntity(
      id: json['id'] as int? ?? 0,
      tenantId: json['tenantId'] as int? ?? 0,
      memberCode:
          json['memberCode'] as String? ?? json['code'] as String? ?? '-',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      tier: json['tier'] as String? ?? 'bronze',
      points:
          (json['points'] as num?)?.toInt() ??
          (json['point'] as num?)?.toInt() ??
          0,
      totalSpent: toDouble(json['totalSpent']),
      totalVisits:
          (json['totalVisits'] as num?)?.toInt() ??
          (json['visits'] as num?)?.toInt() ??
          0,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'].toString())
          : null,
      joinDate: json['joinDate'] != null
          ? (DateTime.tryParse(json['joinDate'].toString()) ?? DateTime.now())
          : (json['createdAt'] != null
                ? (DateTime.tryParse(json['createdAt'].toString()) ??
                      DateTime.now())
                : DateTime.now()),
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tenantId,
    memberCode,
    name,
    phone,
    email,
    tier,
    points,
    totalSpent,
    totalVisits,
    birthDate,
    joinDate,
    address,
    notes,
    isActive,
  ];
}
