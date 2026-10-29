import 'package:flutter/material.dart';

/// Dedicated color palette for the Restaurant (self-order, kasir, kitchen,
/// waiter) modules. Kept separate from [AppColors] so the existing app
/// theme is not affected.
class RestaurantColors {
  RestaurantColors._();

  static const Color primaryBrown = Color(0xFF3E2723);
  static const Color darkBrown = Color(0xFF2A1A16);
  static const Color accentOrange = Color(0xFFE8770D);
  static const Color accentOrangeLight = Color(0xFFFFA24C);
  static const Color accentblueLight = Color(0xFF4C97FF);

  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEDE6DC);
  static const Color cardImageBackground = Color(0xFFA13B22);

  static const Color textPrimary = Color(0xFF2A1A16);
  static const Color textSecondary = Color(0xFF8A7B71);
  static const Color textThird = Color(0xFF665E58);
  static const Color textMuted = Color(0xFFB2A79C);

  static const Color success = Color(0xFF2E9E4F);
  static const Color successBg = Color(0xFFE7F6EA);
  static const Color warning = Color(0xFFE8770D);
  static const Color warningBg = Color(0xFFFFF1E0);
  static const Color danger = Color(0xFFE05353);
  static const Color dangerBg = Color(0xFFFCEAEA);
  static const Color info = Color(0xFF2F7CE0);

  static const LinearGradient bannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color.fromARGB(255, 95, 47, 2), Color.fromARGB(255, 53, 23, 1)],
  );
}
