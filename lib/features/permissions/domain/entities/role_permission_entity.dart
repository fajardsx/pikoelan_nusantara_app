import 'package:equatable/equatable.dart';

/// Privilege satu menu untuk satu role.
/// Field mengikuti response `permissions[]` pada `GET api/permissions`.
class RolePermissionEntity extends Equatable {
  final String menuKey;
  final String label;
  final bool canCreate;
  final bool canRead;
  final bool canUpdate;
  final bool canDelete;

  const RolePermissionEntity({
    required this.menuKey,
    required this.label,
    required this.canCreate,
    required this.canRead,
    required this.canUpdate,
    required this.canDelete,
  });

  factory RolePermissionEntity.fromJson(Map<String, dynamic> json) {
    return RolePermissionEntity(
      menuKey: json['menuKey'] as String? ?? '',
      label:
          json['label'] as String? ?? json['menuKey'] as String? ?? '',
      canCreate: json['canCreate'] as bool? ?? false,
      canRead: json['canRead'] as bool? ?? false,
      canUpdate: json['canUpdate'] as bool? ?? false,
      canDelete: json['canDelete'] as bool? ?? false,
    );
  }

  /// Urutan aksi CRUD sesuai `ACTIONS` di backend
  /// (`src/config/permissions.js`).
  static const List<String> actionKeys = [
    'create',
    'read',
    'update',
    'delete',
  ];

  static const Map<String, String> actionLabels = {
    'create': 'Tambah',
    'read': 'Lihat',
    'update': 'Ubah',
    'delete': 'Hapus',
  };

  /// Body item untuk `PUT api/permissions/:role`.
  Map<String, dynamic> toJson() {
    return {
      'menuKey': menuKey,
      'canCreate': canCreate,
      'canRead': canRead,
      'canUpdate': canUpdate,
      'canDelete': canDelete,
    };
  }

  bool flagFor(String action) {
    switch (action) {
      case 'create':
        return canCreate;
      case 'read':
        return canRead;
      case 'update':
        return canUpdate;
      case 'delete':
        return canDelete;
      default:
        return false;
    }
  }

  RolePermissionEntity copyWith({
    String? menuKey,
    String? label,
    bool? canCreate,
    bool? canRead,
    bool? canUpdate,
    bool? canDelete,
  }) {
    return RolePermissionEntity(
      menuKey: menuKey ?? this.menuKey,
      label: label ?? this.label,
      canCreate: canCreate ?? this.canCreate,
      canRead: canRead ?? this.canRead,
      canUpdate: canUpdate ?? this.canUpdate,
      canDelete: canDelete ?? this.canDelete,
    );
  }

  /// Ubah satu flag berdasarkan nama aksi (`create`/`read`/`update`/`delete`).
  RolePermissionEntity withFlag(String action, bool value) {
    switch (action) {
      case 'create':
        return copyWith(canCreate: value);
      case 'read':
        return copyWith(canRead: value);
      case 'update':
        return copyWith(canUpdate: value);
      case 'delete':
        return copyWith(canDelete: value);
      default:
        return this;
    }
  }

  /// Beri/cabut semua aksi CRUD sekaligus.
  RolePermissionEntity withAllFlags(bool value) {
    return copyWith(
      canCreate: value,
      canRead: value,
      canUpdate: value,
      canDelete: value,
    );
  }

  bool get hasAnyAccess => canCreate || canRead || canUpdate || canDelete;

  @override
  List<Object?> get props => [
    menuKey,
    label,
    canCreate,
    canRead,
    canUpdate,
    canDelete,
  ];
}
