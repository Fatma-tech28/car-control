import 'package:flutter/material.dart';

/// Central color system for the app.
///
/// The "brand blues" are the exact palette supplied by the client
/// (F0F3FA -> 395886). They are used across the dashboard gauges and
/// chart fills. The dark shell, turquoise and pink accents are pulled
/// from the control-page reference screenshot (dark dashboard with a
/// pink circular "drive" button and turquoise readouts).
class AppColors {
  AppColors._();

  // --- Brand blue ramp (lightest -> darkest) ---
  static const Color blue50 = Color(0xFFF0F3FA);
  static const Color blue100 = Color(0xFFD5DEEF);
  static const Color blue200 = Color(0xFFB1C9EF);
  static const Color blue300 = Color(0xFF8AAEE0);
  static const Color blue400 = Color(0xFF628ECB);
  static const Color blue500 = Color(0xFF395886);

  // --- Dark shell (control page reference) ---
  static const Color background = Color(0xFF0C1220);
  static const Color surface = Color(0xFF141B2E);
  static const Color surfaceRaised = Color(0xFF1B2440);
  static const Color surfaceOutline = Color(0xFF2A3557);

  // --- Accents ---
  static const Color turquoise = Color(0xFF2ED9C3);
  static const Color turquoiseDim = Color(0xFF1B8F81);
  static const Color pink = Color(0xFFFF3D8A);
  static const Color pinkDim = Color(0xFFB92E64);

  // --- Status ---
  static const Color danger = Color(0xFFFF3B4E);
  static const Color warning = Color(0xFFFFB020);
  static const Color success = Color(0xFF34D399);

  // --- Text ---
  static const Color textPrimary = Color(0xFFF3F6FC);
  static const Color textSecondary = Color(0xFF8C97B8);
  static const Color textOnLight = Color(0xFF1E2740);

  static const List<Color> gaugeGradient = [blue200, blue300, blue400, blue500];
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.turquoise,
        secondary: AppColors.pink,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: 'Roboto',
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.turquoise,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
