import 'package:equatable/equatable.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_payment_entity.dart';

class TenantEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final bool isActive;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? qrisUrl;
  final String? rekening;
  final TenantPaymentEntity? tenantPayment;

  const TenantEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    this.qrisUrl,
    this.rekening,
    this.tenantPayment,
  });

  factory TenantEntity.fromJson(Map<String, dynamic> json) {
    return TenantEntity(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      isActive:
          json['isActive'] as bool? ?? json['is_active'] as bool? ?? false,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logoUrl: json['logo_url'] as String? ?? json['logoUrl'] as String?,
      qrisUrl: json['qris_url'] as String? ?? json['qrisUrl'] as String?,
      rekening: json['rekening'] as String?,
      // Handle payments being either a map or a list of maps. If it's a list, take the first element.
      tenantPayment: json['payments'] != null
          ? (json['payments'] is List && json['payments'].isNotEmpty
                ? TenantPaymentEntity.fromJson(
                    json['payments'][0] as Map<String, dynamic>,
                  )
                : null)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'isActive': isActive,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (qrisUrl != null) 'qris_url': qrisUrl,
      if (rekening != null) 'bankAccountNumber': rekening,
      if (tenantPayment != null) 'payments': tenantPayment!.toJson(),
    };
  }

  TenantEntity copyWith({
    int? id,
    String? name,
    String? slug,
    bool? isActive,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    String? qrisUrl,
    String? rekening,
    TenantPaymentEntity? tenantPayment,
  }) {
    return TenantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      qrisUrl: qrisUrl ?? this.qrisUrl,
      rekening: rekening ?? this.rekening,
      tenantPayment: tenantPayment ?? this.tenantPayment,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    isActive,
    address,
    phone,
    email,
    logoUrl,
    qrisUrl,
    rekening,
    tenantPayment,
  ];
}
