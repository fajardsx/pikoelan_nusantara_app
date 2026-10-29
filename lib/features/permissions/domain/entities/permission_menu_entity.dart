import 'package:equatable/equatable.dart';

/// Satu menu/modul yang hak aksesnya bisa diatur.
/// Sumbernya `menus` pada `GET api/permissions`.
class PermissionMenuEntity extends Equatable {
  final String key;
  final String label;

  const PermissionMenuEntity({required this.key, required this.label});

  factory PermissionMenuEntity.fromJson(Map<String, dynamic> json) {
    return PermissionMenuEntity(
      key: json['key'] as String? ?? json['menuKey'] as String? ?? '',
      label:
          json['label'] as String? ??
          json['key'] as String? ??
          json['menuKey'] as String? ??
          '',
    );
  }

  @override
  List<Object?> get props => [key, label];
}
