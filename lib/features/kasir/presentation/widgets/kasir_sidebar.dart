import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/features/permissions/presentation/provider/permission_provider.dart';
import 'package:restauran_menu/shared/widgets/side_bar_tile.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../notifications/presentation/widgets/order_stream_status_badge.dart';

class KasirSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  const KasirSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  static const _expandedWidth = 220.0;
  static const _collapsedWidth = 76.0;

  static const _items = [
    (icon: Icons.receipt, label: 'Buat Pesanan'),
    (icon: Icons.receipt_long_rounded, label: 'Daftar Pesanan'),
    (icon: Icons.menu_book_rounded, label: 'Menu'),
    (icon: Icons.swap_horiz_rounded, label: 'Transaksi'),
    (icon: Icons.bar_chart_rounded, label: 'Laporan'),
    (icon: Icons.settings_rounded, label: 'Pengaturan'),
    (icon: Icons.print, label: 'Print Setup'),
  ];

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
                              defaultValue: "MenuMaju",
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const Text(
                            "Kasir",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
            ...List.generate(_items.length, (index) {
              // Map index to permission menuKey (skip first two which are always allowed)
              String? menuKey;
              switch (index) {
                case 2:
                  menuKey = 'menu';
                  break;
                case 3:
                  menuKey = 'transactions';
                  break;
                case 4:
                  menuKey = 'reports';
                  break;
                case 5:
                  menuKey = 'settings';
                  break;
                default:
                  menuKey = null;
              }
              // If a menuKey exists and user lacks read permission, hide tile
              if (menuKey != null) {
                final permission = Provider.of<PermissionProvider>(
                  context,
                  listen: false,
                );
                if (!permission.can(menuKey, 'read')) {
                  return const SizedBox.shrink();
                }
              }
              final item = _items[index];
              final selected = index == selectedIndex;
              return SidebarTile(
                icon: item.icon,
                label: item.label,
                selected: selected,
                collapsed: collapsed,
                onTap: () => onSelect(index),
              );
            }),
            const Spacer(),
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
