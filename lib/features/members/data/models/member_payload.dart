import 'package:dio/dio.dart';

class MemberPayload {
  final String name;
  final String phone;
  final String? email;
  final String? birthDate;
  final String? address;
  final String? notes;

  MemberPayload({
    required this.name,
    required this.phone,
    this.email,
    this.birthDate,
    this.address,
    this.notes,
  });

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (birthDate != null) 'birthDate': birthDate,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (birthDate != null) 'birthDate': birthDate,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
    };
  }
}
