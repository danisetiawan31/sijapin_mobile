import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema Material 3 Resmi RSUP Dr. Sitanala Tangerang
class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surfaceBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandWarmBronze,
        primary: AppColors.brandWarmBronze,
        onPrimary: Colors.white,
        secondary: AppColors.brandGoldenCaramel,
        surface: AppColors.surfaceBg,
        error: AppColors.dangerCrimson,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceBg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
    );
  }
}
