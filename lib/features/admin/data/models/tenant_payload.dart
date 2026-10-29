import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restauran_menu/features/admin/domain/entities/tenant_payment_entity.dart';

class TenantPayload {
  final String name;
  final String? slug;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? qrisUrl;
  final String? rekening;

  /// File logo baru dari [_pickImage] (XFile image_picker).
  /// Kalau tidak null, request dikirim sebagai `multipart/form-data`.
  final XFile? logoFile;
  final XFile? qrisFile;

  final TenantPaymentEntity? tenantPayment;

  TenantPayload({
    required this.name,
    this.slug,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    this.logoFile,
    this.qrisUrl,
    this.qrisFile,
    this.rekening,
    this.tenantPayment,
  });

  bool get hasFile => logoFile != null;
  bool get hasQrisFile => qrisFile != null;

  Map<String, dynamic> toJson() {
    String? clean(String? v) {
      final t = v?.trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    final slugValue = clean(slug);
    final addressValue = clean(address);
    final phoneValue = clean(phone);
    final emailValue = clean(email);
    final rekeningValue = clean(rekening);
    final logoValue = clean(logoUrl);
    final qrisValue = clean(qrisUrl);
    return {
      'name': name.trim(),
      'slug': ?slugValue,
      'address': ?addressValue,
      'phone': ?phoneValue,
      'email': ?emailValue,
      'logo_url': ?logoValue,
      'qris_url': ?qrisValue,
      'bankAccountNumber': ?rekeningValue,
      "payment": tenantPayment?.toJson(),
    };
  }

  /// Build `multipart/form-data` untuk update tenant + upload logo.
  ///
  /// Pola ini mengikuti [MenuItemPayload.toFormData]: pakai
  /// `XFile.readAsBytes()` supaya jalan di Web maupun Android/iOS
  /// tanpa `dart:io`.
  ///
  /// Key file dikirim sebagai `logo` (konvensi multer/express).
  /// `logo_url` tetap dikirim kalau ada (untuk backend yang hanya
  /// terima URL / tidak ada file baru).
  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': name.trim(),
      if (slug?.trim().isNotEmpty == true) 'slug': slug!.trim(),
      if (address?.trim().isNotEmpty == true) 'address': address!.trim(),
      if (phone?.trim().isNotEmpty == true) 'phone': phone!.trim(),
      if (email?.trim().isNotEmpty == true) 'email': email!.trim(),
      if (rekening?.trim().isNotEmpty == true)
        'bankAccountNumber': rekening!.trim(),
      if (logoUrl?.trim().isNotEmpty == true) 'logo_url': logoUrl!.trim(),
      if (qrisUrl?.trim().isNotEmpty == true) 'qris_url': qrisUrl!.trim(),
      if (tenantPayment != null) 'payment': tenantPayment?.toJson(),
    };

    if (logoFile != null) {
      final bytes = await logoFile!.readAsBytes();
      final filename = logoFile!.name.isNotEmpty
          ? logoFile!.name
          : 'tenant-logo.jpg';
      map['logo'] = MultipartFile.fromBytes(bytes, filename: filename);
    }

    if (qrisFile != null) {
      final bytes = await qrisFile!.readAsBytes();
      final filename = qrisFile!.name.isNotEmpty
          ? qrisFile!.name
          : 'tenant-qris.jpg';
      map['qris'] = MultipartFile.fromBytes(bytes, filename: filename);
    }

    return FormData.fromMap(map);
  }
}
