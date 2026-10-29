import 'package:equatable/equatable.dart';

import 'role_permission_entity.dart';

/// Kumpulan privilege satu role (satu baris `roles[]` pada matrix).
class RolePermissionsEntity extends Equatable {
  final String role;
  final List<RolePermissionEntity> permissions;

  const RolePermissionsEntity({required this.role, required this.permissions});

  factory RolePermissionsEntity.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'] as List? ?? const [];
    return RolePermissionsEntity(
      role: json['role'] as String? ?? '',
      permissions: rawPermissions
          .whereType<Map>()
          .map(
            (item) => RolePermissionEntity.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  /// Label role versi Indonesia. `superadmin` tidak muncul di matrix
  /// (backend tidak mengizinkannya diubah) tapi tetap dipetakan.
  static const Map<String, String> roleLabels = {
    'owner': 'Pemilik',
    'manager': 'Manajer',
    'staff': 'Staf',
    'kasir': 'Kasir',
    'waiter': 'Pelayan',
    'kitchen': 'Dapur',
    'superadmin': 'Superadmin',
  };

  String get label => roleLabels[role] ?? role;

  RolePermissionEntity? permissionFor(String menuKey) {
    for (final permission in permissions) {
      if (permission.menuKey == menuKey) return permission;
    }
    return null;
  }

  bool can(String menuKey, String action) {
    return permissionFor(menuKey)?.flagFor(action) ?? false;
  }

  RolePermissionsEntity copyWith({List<RolePermissionEntity>? permissions}) {
    return RolePermissionsEntity(
      role: role,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Ganti satu baris menu; kalau menu belum ada, tambahkan di akhir.
  RolePermissionsEntity updatePermission(RolePermissionEntity permission) {
    final index = permissions.indexWhere(
      (item) => item.menuKey == permission.menuKey,
    );
    final next = List<RolePermissionEntity>.from(permissions);
    if (index == -1) {
      next.add(permission);
    } else {
      next[index] = permission;
    }
    return copyWith(permissions: next);
  }

  /// Ubah satu flag pada satu menu.
  RolePermissionsEntity setFlag({
    required String menuKey,
    required String action,
    required bool value,
  }) {
    final current = permissionFor(menuKey);
    if (current == null) return this;
    return updatePermission(current.withFlag(action, value));
  }

  /// Beri/cabut semua aksi pada semua menu milik role ini.
  RolePermissionsEntity setAll(bool value) {
    return copyWith(
      permissions: permissions
          .map((permission) => permission.withAllFlags(value))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [role, permissions];
}
