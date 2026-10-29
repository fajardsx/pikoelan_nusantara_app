import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';

import '../../domain/entities/permission_menu_entity.dart';
import '../../domain/entities/role_permission_entity.dart';

/// Tabel matrix privilege: baris = menu, kolom = aksi CRUD
/// (Tambah / Lihat / Ubah / Hapus), isi = checkbox.
class PermissionMatrixTable extends StatelessWidget {
  final List<PermissionMenuEntity> menus;
  final List<String> actions;
  final List<RolePermissionEntity> permissions;
  final bool enabled;
  final void Function(String menuKey, String action, bool value) onToggle;

  const PermissionMatrixTable({
    super.key,
    required this.menus,
    required this.actions,
    required this.permissions,
    required this.enabled,
    required this.onToggle,
  });

  static const double _actionColumnWidth = 74;
  static const double _minTableWidth = 520;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _minTableWidth;
        final tableWidth = available < _minTableWidth
            ? _minTableWidth
            : available;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Divider(height: 1, color: RestaurantColors.cardBorder),
                if (menus.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'Belum ada menu yang bisa diatur.',
                      style: TextStyle(color: RestaurantColors.textSecondary),
                    ),
                  )
                else
                  ...menus.map(_buildRow),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: RestaurantColors.textSecondary,
              ),
            ),
          ),
          ...actions.map(
            (action) => SizedBox(
              width: _actionColumnWidth,
              child: Center(
                child: Text(
                  RolePermissionEntity.actionLabels[action] ?? action,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: RestaurantColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(PermissionMenuEntity menu) {
    final permission = _permissionFor(menu.key);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: RestaurantColors.cardBorder, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.label.isEmpty ? menu.key : menu.label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: RestaurantColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    menu.key,
                    style: const TextStyle(
                      fontSize: 11,
                      color: RestaurantColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...actions.map(
            (action) => SizedBox(
              width: _actionColumnWidth,
              child: Center(
                child: Checkbox(
                  value: permission?.flagFor(action) ?? false,
                  visualDensity: VisualDensity.compact,
                  activeColor: RestaurantColors.accentOrange,
                  onChanged: (!enabled || permission == null)
                      ? null
                      : (value) => onToggle(menu.key, action, value ?? false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  RolePermissionEntity? _permissionFor(String menuKey) {
    for (final permission in permissions) {
      if (permission.menuKey == menuKey) return permission;
    }
    return null;
  }
}
