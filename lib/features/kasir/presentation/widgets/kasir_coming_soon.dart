import 'package:flutter/material.dart';
import '../../../../core/themes/restaurant_colors.dart';

class KasirComingSoon extends StatelessWidget {
  final IconData icon;
  final String title;

  const KasirComingSoon({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RestaurantColors.background,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: RestaurantColors.textMuted),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: RestaurantColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fitur ini akan segera hadir',
            style: TextStyle(color: RestaurantColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
