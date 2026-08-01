import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_radius.dart';
import 'app_custom_tokens.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkGoldPrimary,
        surface: AppColors.darkSurface1,
        error: AppColors.darkExpense,
        onPrimary: AppColors.darkCanvas,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkTextPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayXL,
        displayMedium: AppTypography.heading1,
        displaySmall: AppTypography.heading2,
        headlineMedium: AppTypography.heading3,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyBase,
        bodySmall: AppTypography.caption,
        labelSmall: AppTypography.microTag,
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppCustomTokens(
          incomeColor: AppColors.darkIncome,
          expenseColor: AppColors.darkExpense,
          goldAccent: AppColors.darkGoldPrimary,
          goldGlow: AppColors.darkGoldGlow,
          surfaceGlass: AppColors.darkSurfaceGlass,
          borderGlass: AppColors.darkBorderGlass,
          borderGoldRim: AppColors.darkBorderGoldRim,
          textGold: AppColors.darkTextGold,
          cardBorderRadius: AppRadius.radiusMd,
          gridUnit: AppSpacing.space2,
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightCanvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightGoldPrimary,
        surface: AppColors.lightSurface1,
        error: AppColors.lightExpense,
        onPrimary: AppColors.lightCanvas,
        onSurface: AppColors.lightTextPrimary,
        onError: AppColors.lightCanvas,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayXL,
        displayMedium: AppTypography.heading1,
        displaySmall: AppTypography.heading2,
        headlineMedium: AppTypography.heading3,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyBase,
        bodySmall: AppTypography.caption,
        labelSmall: AppTypography.microTag,
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppCustomTokens(
          incomeColor: AppColors.lightIncome,
          expenseColor: AppColors.lightExpense,
          goldAccent: AppColors.lightGoldPrimary,
          goldGlow: AppColors.darkGoldGlow,
          surfaceGlass: Color(0x66FFFFFF),
          borderGlass: Color(0x1A000000),
          borderGoldRim: Color(0x33B8860B),
          textGold: AppColors.lightGoldPrimary,
          cardBorderRadius: AppRadius.radiusMd,
          gridUnit: AppSpacing.space2,
        ),
      ],
    );
  }
}
