import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/core/di/injector.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/auth/presentation/provider/auth_provider.dart';
import 'package:restauran_menu/features/permissions/presentation/provider/permission_provider.dart';
import 'package:restauran_menu/features/sidemenu/presentation/widgets/menu_key.dart';
import 'package:restauran_menu/shared/widgets/side_bar_tile.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../notifications/presentation/widgets/order_stream_status_badge.dart';

class MenuSideBar extends StatelessWidget {
  final String roleName;
  final String selectedIndex;
  final ValueChanged<String> onSelect;
  final VoidCallback onLogout;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  const MenuSideBar({
    super.key,
    required this.roleName,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  static const _expandedWidth = 220.0;
  static const _collapsedWidth = 76.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: collapsed ? _collapsedWidth : _expandedWidth,
      color: RestaurantColors.primaryBrown,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 16 : 20,
                24,
                collapsed ? 16 : 20,
                24,
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: RestaurantColors.accentOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getSaveSharedPref(
                              key: SettingsKeys.restaurantName,
                              defaultValue: "Nama Restauran",
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            roleName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Permission‑aware tiles
            Expanded(
              child: ListView(
                children: List.generate(MenuTree.menuitems.length, (index) {
                  // Map index to permission menuKey (skip first two which are always allowed)
                  String? menuKey = MenuTree.menuitems[index].menuKey;
                  // If a menuKey exists and user lacks read permission, hide tile

                  final permission = Provider.of<PermissionProvider>(
                    context,
                    listen: true,
                  );
                  final role = sl<AuthProvider>().user?.role;
                  // if (permission.status == PermissionStatus.loading) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }
                  if (!permission.can(menuKey, 'read')) {
                    if ((role == "kasir" && menuKey == MenuKeys.buatPesanan) ||
                        (role == "kasir" &&
                            menuKey == MenuKeys.daftarPesanan) ||
                        (role == "kasir" && menuKey == MenuKeys.print)) {
                    } else if ((role == "kitchen" &&
                        menuKey == MenuKeys.kitchenDisplay)) {
                    } else if ((role == "waiter" &&
                        menuKey == MenuKeys.waitersDisplay)) {
                    } else {
                      return const SizedBox.shrink();
                    }
                  }

                  final item = MenuTree.menuitems[index];
                  final selected = menuKey == selectedIndex;
                  return SidebarTile(
                    icon: item.icon,
                    label: item.label,
                    selected: selected,
                    collapsed: collapsed,
                    onTap: () => onSelect(menuKey),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 8 : 16,
                vertical: 8,
              ),
              child: Center(
                child: OrderStreamStatusBadge(compact: collapsed, onDark: true),
              ),
            ),
            SidebarTile(
              icon: Icons.logout_rounded,
              label: 'Keluar',
              selected: false,
              collapsed: collapsed,
              onTap: onLogout,
            ),
            const Divider(height: 1, color: Colors.white24),
            SidebarTile(
              icon: collapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              label: collapsed ? 'Perluas' : 'Ciutkan',
              selected: false,
              collapsed: collapsed,
              onTap: onToggleCollapse,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
