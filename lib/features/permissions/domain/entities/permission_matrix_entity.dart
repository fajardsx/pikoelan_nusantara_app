import 'package:equatable/equatable.dart';

import 'permission_menu_entity.dart';
import 'role_permission_entity.dart';
import 'role_permissions_entity.dart';

/// Matriks privilege semua role di satu tenant.
/// Sumbernya `data` pada `GET api/permissions`.
class PermissionMatrixEntity extends Equatable {
  final int? tenantId;
  final List<PermissionMenuEntity> menus;
  final List<String> actions;
  final List<RolePermissionsEntity> roles;

  const PermissionMatrixEntity({
    required this.tenantId,
    required this.menus,
    required this.actions,
    required this.roles,
  });

  factory PermissionMatrixEntity.fromJson(Map<String, dynamic> json) {
    final rawMenus = json['menus'] as List? ?? const [];
    final rawActions = json['actions'] as List? ?? const [];
    final rawRoles = json['roles'] as List? ?? const [];

    final actions = rawActions.map((action) => action.toString()).toList();

    return PermissionMatrixEntity(
      tenantId: (json['tenantId'] as num?)?.toInt(),
      menus: rawMenus
          .whereType<Map>()
          .map(
            (menu) => PermissionMenuEntity.fromJson(Map<String, dynamic>.from(menu)),
          )
          .toList(),
      actions: actions.isEmpty ? RolePermissionEntity.actionKeys : actions,
      roles: rawRoles
          .whereType<Map>()
          .map(
            (role) => RolePermissionsEntity.fromJson(
              Map<String, dynamic>.from(role),
            ),
          )
          .toList(),
    );
  }

  List<String> get roleNames => roles.map((role) => role.role).toList();

  RolePermissionsEntity? roleFor(String? role) {
    if (role == null) return null;
    for (final item in roles) {
      if (item.role == role) return item;
    }
    return null;
  }

  PermissionMatrixEntity copyWith({
    int? tenantId,
    List<PermissionMenuEntity>? menus,
    List<String>? actions,
    List<RolePermissionsEntity>? roles,
  }) {
    return PermissionMatrixEntity(
      tenantId: tenantId ?? this.tenantId,
      menus: menus ?? this.menus,
      actions: actions ?? this.actions,
      roles: roles ?? this.roles,
    );
  }

  /// Ganti privilege satu role, role lain tetap.
  PermissionMatrixEntity withRolePermissions(
    String role,
    List<RolePermissionEntity> permissions,
  ) {
    return copyWith(
      roles: roles
          .map(
            (item) =>
                item.role == role ? item.copyWith(permissions: permissions) : item,
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [tenantId, menus, actions, roles];
}
