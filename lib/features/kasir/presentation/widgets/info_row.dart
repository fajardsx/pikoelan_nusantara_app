import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: RestaurantColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: RestaurantColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
