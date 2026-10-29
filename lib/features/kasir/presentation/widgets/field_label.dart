import 'package:flutter/material.dart';
import 'package:restauran_menu/core/themes/restaurant_colors.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: RestaurantColors.textSecondary,
        ),
      ),
    );
  }
}
