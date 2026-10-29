import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primaryDark = Color(0xFF294B34);
  static const primarySoft = Color(0xFFC4622D);

  static const accent = Color(0xFFC4622D);
  static const accentSoft = Color(0xFFF5E3D3);

  static const danger = Color(0xFF9C3B3B);
  static const dangerSoft = Color(0xFFF2DEDA);

  static const bg = Color(0xFFFBFAF4);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF262420);
  static const inkSoft = Color(0xFF726D61);
  static const inkFaint = Color(0xFFA29C8C);
  static const line = Color(0xFFE7E0CE);

  MaterialColor get neutral => const MaterialColor(
    0xFF27364B, // 80
    <int, Color>{
      0: Colors.white,
      10: Color(0xFFFEFEFE), // Background
      20: Color(0xFFFFFFFF),
      30: Color(0xFFF2F2F2), // Disabled Button
      40: Color(0xFFD9D9D9), // Border
      50: Color(0xFFC0C0C0), // Disabled Button Font
      60: Color(0xFF828282), // Light Font
      70: Color(0xFF636363), // Gray Font
      80: Color(0xFF4A4A4A), // Primary Font
      90: Color(0xFF3C3C3C),
      100: Colors.black, // Dark Font
    },
  );

  Color get white => neutral[0]!;

  Color get background => neutral[10]!;

  Color get pageBackground => neutral[10]!;

  Color get backgroundTextField => neutral[20]!;

  Color get disabledButton => neutral[30]!;

  Color get neutralHover => neutral[30]!;

  Color get border => neutral[40]!;

  Color get disabledButtonFont => neutral[50]!;

  Color get placeholder => neutral[50]!;

  Color get neutralIcon => neutral[50]!;

  Color get lightFont => neutral[60]!;

  Color get grayFont => neutral[70]!;

  Color get darkGrayFont => neutral[80]!;

  Color get font => neutral[0]!;

  Color get surfaceBg => neutral[90]!;

  Color get black => neutral[100]!;

  MaterialColor get secondary => const MaterialColor(
    0xFF11A791, // 20
    <int, Color>{
      0: Color(0xFFF2F5FC),
      10: Color(0xFFD0D5E2),
      20: Color(0xFF00FFDC),
      30: Color(0xFF00D0AF),
      40: Color(0xFF1D2D54),
      50: Color(0xff11A791),
    },
  );

  MaterialColor get primarySwatch => const MaterialColor(
    0xFF3C5CA9, // 20
    <int, Color>{
      50: Color(0xFFF2F5FC),
      100: Color(0xFFBEC9E2),
      200: Color(0xFF9DADD4),
      300: Color(0xFF7D92C6),
      400: Color(0xFF5D77B7),
      500: Color(0xFF3C5CA9),
      600: Color(0xFF324D8D),
      700: Color(0xFF283D71),
      800: Color(0xFF1E2E55),
      900: Color(0xFF141F38),
    },
  );

  MaterialColor get gradient => const MaterialColor(
    0xFF3C5CA9, // 20
    <int, Color>{0: Color(0xFF3C5CA9), 10: Color(0xFF587FDD)},
  );

  MaterialColor get primary => const MaterialColor(
    0xFF11A791, // 50
    <int, Color>{
      0: Color(0xFFDFE6FD),
      10: Color(0xFFFCDCD4),
      20: Color(0xFFF9B9A8),
      30: Color(0xFFF7967D),
      40: Color(0xFFF47351),
      50: Color(0xFF11A791),
      60: Color(0xFFC1401E),
      70: Color(0xFF913017),
      80: Color(0xFF60200F),
      90: Color(0xFF301008),
      100: Color(0xFF000000),
    },
  );

  MaterialColor get info => const MaterialColor(
    0xFF3B90FF, // 20
    <int, Color>{
      0: Color(0xFFF0F3FF),
      10: Color(0xFFB1C5F6),
      20: Color(0xFF3B90FF),
      30: Color(0xFF114CD6),
      40: Color(0xFF11317D),
    },
  );

  MaterialColor get success => const MaterialColor(
    0xff13AF99, // 20
    <int, Color>{
      0: Color(0xFFE1F9F2),
      10: Color(0xFFB6EADC),
      20: Color(0xFF25C196),
      30: Color(0xFF1FA17D),
      40: Color(0xFF20563C),
    },
  );

  MaterialColor get warning => const MaterialColor(
    0xFFFF9D05, // 20
    <int, Color>{
      0: Color(0xFFFFF9F2),
      10: Color(0xFFEECEB0),
      20: Color(0xFFFF9D05),
      30: Color(0xFFBF6919),
      40: Color(0xFF734011),
    },
  );

  MaterialColor get error => const MaterialColor(
    0xffF34040, // 20
    <int, Color>{
      0: Color(0xFFFFF5F9),
      10: Color(0xFFFFAACE),
      20: Color(0xFFFF006C),
      30: Color(0xFFD42A72),
      40: Color(0xFF800036),
    },
  );

  Gradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondary.hover, primary, primary.hover],
  );

  Gradient get mobileBackgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.topRight,
    colors: [gradient.surface, gradient.splash],
  );

  ThemeData get primaryDatePicker => ThemeData.light().copyWith(
    primaryColor: primary,
    colorScheme: ColorScheme.light(primary: primary),
    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
  );

  List<Color> get backgroundColors => [black, const Color(0xFFFFF8DC)];

  List<Color> get foregroundColors => [
    const Color(0xFF3267E3),
    const Color(0xFFCD7B2E),
    const Color(0xFF5E81F4),
    const Color(0xFFFF006C),
    const Color(0xFF25C196),
    const Color(0xFFA660BA),
    const Color(0xffF2DA42),
    const Color(0xFF34303E),
  ];
}

/// Example: appColors.primary.surface

AppColors get appColors {
  return AppColors._();
}

extension AliasMaterialColor on MaterialColor {
  Color get surface => this[0] ?? this;

  Color get splash => this[10] ?? this;

  Color get main => this[20] ?? this;

  Color get hover => this[30] ?? this;

  Color get pressed => this[40] ?? this;
}
