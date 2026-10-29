import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';

class PreferenceSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PreferenceSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: RestaurantColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12.5,
          color: RestaurantColors.textSecondary,
        ),
      ),
      value: value,
      activeThumbColor: RestaurantColors.primaryBrown,
      onChanged: onChanged,
    );
  }
}
