import 'package:flutter/material.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';
import 'package:restauran_menu/shared/widgets/side_bar_tile.dart';

import '../../../../core/themes/restaurant_colors.dart';

class AdminMenuBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  const AdminMenuBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    required this.collapsed,
    required this.onToggleCollapse,
  });

  static const _items = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.receipt, label: 'Buat Pesanan'), // Khusus Kasir
    (icon: Icons.receipt_long_rounded, label: 'Daftar Pesanan'), // Khusus kasir
    (icon: Icons.menu_book_rounded, label: 'Menu'),
    (icon: Icons.store_rounded, label: 'Stock'),
    (icon: Icons.people_alt_rounded, label: 'Staf'),
    (icon: Icons.verified_user_rounded, label: 'Hak Akses'),
    (icon: Icons.swap_horiz_rounded, label: 'Transaksi'),
    (icon: Icons.local_offer_rounded, label: 'Promosi'),
    (icon: Icons.card_membership_rounded, label: 'Member'),
    (icon: Icons.print, label: 'Print Setup'),
    (icon: Icons.settings_rounded, label: 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: RestaurantColors.accentOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
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
                          'Admin Panel',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final selected = index == selectedIndex;
                  return SidebarTile(
                    icon: item.icon,
                    label: item.label,
                    selected: selected,
                    collapsed: false,
                    onTap: () => onSelect(index),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
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
