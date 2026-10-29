import 'package:equatable/equatable.dart';

/// Dart entity that mirrors the Sequelize model
/// `src/models/tenantPayment.js` in the backend.
///
/// Fields:
/// - `id` – primary key, auto‑incremented (int, may be null when creating)
/// - `tenantId` – foreign key to the tenant (int, required)
/// - `qrisUrl` – optional QR‑IS payment link (String?)
/// - `bankAccountName` – optional account holder name (String?)
/// - `bankAccountNumber` – optional account number (String?) – numeric validation is done on the backend
/// - `phoneConfirmation` – optional phone confirmation text (String?)
/// - `deliveryDescription` – optional description for delivery (String?)
/// - `createdAt` / `updatedAt` – timestamps added by Sequelize (DateTime?).
///
/// The class implements `Equatable` for value comparison and provides
/// `fromJson`, `toJson` and a `copyWith` helper.
class TenantPaymentEntity extends Equatable {
  final int? id;
  final int tenantId;
  final String? qrisUrl;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? phoneConfirmation;
  final String? deliveryDescription;

  const TenantPaymentEntity({
    this.id,
    required this.tenantId,
    this.qrisUrl,
    this.bankAccountName,
    this.bankAccountNumber,
    this.phoneConfirmation,
    this.deliveryDescription,
  });

  /// Factory constructor to create an instance from a JSON map
  /// (typically the response from the backend API).
  factory TenantPaymentEntity.fromJson(Map<String, dynamic> json) {
    return TenantPaymentEntity(
      id: json['id'] as int?,
      tenantId: json['tenantId'] as int,
      qrisUrl: json['qrisUrl'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      phoneConfirmation: json['phoneConfirmation'] as String?,
      deliveryDescription: json['deliveryDescription'] as String?,
    );
  }

  /// Convert the entity back to a JSON‑compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'qrisUrl': qrisUrl,
      'bankAccountName': bankAccountName,
      'bankAccountNumber': bankAccountNumber,
      'phoneConfirmation': phoneConfirmation,
      'deliveryDescription': deliveryDescription,
    };
  }

  /// Helper to create a modified copy of the instance.
  TenantPaymentEntity copyWith({
    int? id,
    int? tenantId,
    String? qrisUrl,
    String? bankAccountName,
    String? bankAccountNumber,
    String? phoneConfirmation,
    String? deliveryDescription,
  }) {
    return TenantPaymentEntity(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      qrisUrl: qrisUrl ?? this.qrisUrl,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      phoneConfirmation: phoneConfirmation ?? this.phoneConfirmation,
      deliveryDescription: deliveryDescription ?? this.deliveryDescription,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tenantId,
    qrisUrl,
    bankAccountName,
    bankAccountNumber,
    phoneConfirmation,
    deliveryDescription,
  ];
}
