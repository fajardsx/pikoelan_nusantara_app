import 'package:flutter/material.dart';

import '../../../../core/themes/restaurant_colors.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RestaurantColors.background,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola Staf',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: RestaurantColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Atur akun dan peran untuk karyawan restoran',
                    style: TextStyle(color: RestaurantColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur tambah staf segera hadir'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Tambah Staf'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RestaurantColors.primaryBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: RestaurantColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RestaurantColors.cardBorder),
              ),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: const [
                  _StaffItem(
                    name: 'Budi Santoso',
                    role: 'Kasir',
                    phone: '081234567890',
                    isActive: true,
                  ),
                  Divider(height: 1, color: RestaurantColors.cardBorder),
                  _StaffItem(
                    name: 'Siti Aminah',
                    role: 'Waiter',
                    phone: '085678901234',
                    isActive: true,
                  ),
                  Divider(height: 1, color: RestaurantColors.cardBorder),
                  _StaffItem(
                    name: 'Rudi Hartono',
                    role: 'Chef',
                    phone: '089876543210',
                    isActive: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffItem extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final bool isActive;

  const _StaffItem({
    required this.name,
    required this.role,
    required this.phone,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: RestaurantColors.primaryBrown.withValues(
              alpha: 0.1,
            ),
            foregroundColor: RestaurantColors.primaryBrown,
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: RestaurantColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    color: RestaurantColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: RestaurantColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: RestaurantColors.cardBorder),
            ),
            child: Text(
              role,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: RestaurantColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? RestaurantColors.success.withValues(alpha: 0.1)
                  : RestaurantColors.textMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? RestaurantColors.success
                    : RestaurantColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: RestaurantColors.textSecondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
