import 'package:flutter/material.dart';

/// White / Sky-Blue color system — clean, light dashboard aesthetic.
class AppColors {
  AppColors._();

  // --- Sky-blue ramp (lightest -> darkest) ---
  static const Color blue50  = Color(0xFFE8F4FD);
  static const Color blue100 = Color(0xFFD0E9FB);
  static const Color blue200 = Color(0xFFA3D3F7);
  static const Color blue300 = Color(0xFF5DB5F2);
  static const Color blue400 = Color(0xFF2A9DF4); // main sky blue
  static const Color blue500 = Color(0xFF007AFF); // strong accent
  static const Color blue600 = Color(0xFF005FCC);

  // --- Neutral light shell ---
  static const Color background     = Color(0xFFF7F9FC); // page bg
  static const Color surface        = Color(0xFFFFFFFF); // cards
  static const Color surfaceRaised  = Color(0xFFF0F7FF); // tinted cards
  static const Color surfaceOutline = Color(0xFFE3EAF5); // borders

  // --- Accents ---
  static const Color turquoise    = Color(0xFF00C2CB);
  static const Color turquoiseDim = Color(0xFF0097A7);
  static const Color pink         = Color(0xFFFF4D8D);
  static const Color pinkDim      = Color(0xFFD6336C);

  // --- Status ---
  static const Color danger   = Color(0xFFFF3B4E);
  static const Color warning  = Color(0xFFFFB020);
  static const Color success  = Color(0xFF34D399);

  // --- Text ---
  static const Color textPrimary   = Color(0xFF1A1D2B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnLight   = Color(0xFF1A1D2B);

  static const List<Color> gaugeGradient = [blue200, blue300, blue400, blue500];
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.blue500,
        secondary: AppColors.blue400,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: 'Roboto',
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.blue500,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceOutline, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.blue500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceOutline,
        thickness: 1,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
