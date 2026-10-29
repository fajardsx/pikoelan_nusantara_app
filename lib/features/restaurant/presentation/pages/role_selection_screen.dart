import 'package:flutter/material.dart';
import 'package:restauran_menu/core/common/common_utils.dart';
import 'package:restauran_menu/features/admin/presentation/pages/admin_pengaturan_screen.dart';

import '../../../../core/themes/restaurant_colors.dart';
import '../../../../routes/name_route.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RestaurantColors.primaryBrown,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: RestaurantColors.accentOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                getSaveSharedPref(
                  key: SettingsKeys.restaurantName,
                  defaultValue: "MenuMaju",
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih mode aplikasi untuk melanjutkan',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin (Manager)',
                      subtitle: 'Pantau statistik, staf, & pengaturan',
                      enabled: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        NameRoute.adminDashboard,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // _RoleCard(
                    //   icon: Icons.tablet_mac_rounded,
                    //   title: 'Self Order',
                    //   subtitle: 'Pesan langsung dari meja pelanggan',
                    //   enabled: true,
                    //   onTap: () {
                    //     final slug = context
                    //         .read<AuthProvider>()
                    //         .tenant
                    //         ?.slug
                    //         .trim();
                    //     if ((slug ?? '').isEmpty) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(
                    //           content: Text(
                    //             'Data restoran belum tersedia. Login ulang dulu ya.',
                    //           ),
                    //         ),
                    //       );
                    //       return;
                    //     }
                    //     Navigator.pushNamed(
                    //       context,
                    //       NameRoute.customerHome,
                    //       arguments: {"slug": slug},
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 14),
                    _RoleCard(
                      icon: Icons.point_of_sale_rounded,
                      title: 'Kasir (POS)',
                      subtitle: 'Kelola pesanan & pembayaran',
                      enabled: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        NameRoute.kasirDashboard,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RoleCard(
                      icon: Icons.soup_kitchen_rounded,
                      title: 'Kitchen Display',
                      subtitle: 'Pantau pesanan yang perlu disiapkan',
                      enabled: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        NameRoute.kitchenDisplay,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RoleCard(
                      icon: Icons.room_service_rounded,
                      title: 'Waiters',
                      subtitle: 'Antar pesanan & bantu pelanggan',
                      enabled: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        NameRoute.waiterDashboard,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: RestaurantColors.accentOrange.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!enabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Segera',
                      style: TextStyle(color: Colors.white70, fontSize: 10.5),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white70,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
