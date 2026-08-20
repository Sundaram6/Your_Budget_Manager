import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_custom_tokens.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      fontFamily: AppTypography.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkHeroAccentText,
        surface: AppColors.darkSurface1,
        error: AppColors.darkExpense,
        onPrimary: AppColors.darkCanvas,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkTextPrimary,
      ),
      textTheme: const TextTheme(
        // Cabinet Grotesk — 44sp for general large displays (hero balance uses
        // AppTypography.heroBalance directly at 48sp).
        displayLarge: TextStyle(
          fontFamily: AppTypography.cabinetFontFamily,
          fontSize: 44,
          height: 52 / 44,
          fontWeight: FontWeight.w700,
          letterSpacing: -44 * 0.03,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        displayMedium: AppTypography.heading1,
        displaySmall: AppTypography.heading2,
        headlineMedium: AppTypography.heading3,
        // Cabinet Grotesk Bold — section headers across dashboard.
        titleLarge: TextStyle(
          fontFamily: AppTypography.cabinetFontFamily,
          fontSize: 20,
          height: 24 / 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -20 * 0.015,
        ),
        bodyLarge: AppTypography.bodyLg,
        // Satoshi Regular — body copy on dashboard.
        bodyMedium: TextStyle(
          fontFamily: AppTypography.satoshiFontFamily,
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodySmall: AppTypography.caption,
        labelSmall: AppTypography.microTag,
        // Satoshi Bold — button labels and emphasis.
        labelMedium: TextStyle(
          fontFamily: AppTypography.satoshiFontFamily,
          fontSize: 13,
          height: 18 / 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppCustomTokens(
          heroSurfaceColor: AppColors.darkHeroSurface,
          heroTextColor: AppColors.darkHeroAccentText,
          accentGroceries: AppColors.accentGroceriesDark,
          accentShopping: AppColors.accentShopping,
          accentBills: AppColors.accentBills,
          accentTransport: AppColors.accentTransport,
          accentSavings: AppColors.accentSavings,
          accentAlert: AppColors.accentAlert,
          statusTileTintOpacity: 0.15, // 15% in dark mode
          cardBorderRadius: 24.0, // 24-32px radius per spec
          gridUnit: AppSpacing.space2,
          incomeColor: AppColors.accentSavings,
          expenseColor: AppColors.accentAlert,
          goldAccent: AppColors.darkHeroAccentText,
          goldGlow: const Color(0x33FFC64B),
          surfaceGlass: const Color(0x0AFFFFFF),
          borderGlass: const Color(0x26FFFFFF),
          borderGoldRim: const Color(0x33FFC64B),
          textGold: AppColors.darkHeroAccentText,
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightCanvas,
      fontFamily: AppTypography.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightHeroSurface,
        surface: AppColors.lightSurface1,
        error: AppColors.lightExpense,
        onPrimary: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onError: AppColors.lightCanvas,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: AppTypography.cabinetFontFamily,
          fontSize: 44,
          height: 52 / 44,
          fontWeight: FontWeight.w700,
          letterSpacing: -44 * 0.03,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        displayMedium: AppTypography.heading1,
        displaySmall: AppTypography.heading2,
        headlineMedium: AppTypography.heading3,
        titleLarge: TextStyle(
          fontFamily: AppTypography.cabinetFontFamily,
          fontSize: 20,
          height: 24 / 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -20 * 0.015,
        ),
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: TextStyle(
          fontFamily: AppTypography.satoshiFontFamily,
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodySmall: AppTypography.caption,
        labelSmall: AppTypography.microTag,
        labelMedium: TextStyle(
          fontFamily: AppTypography.satoshiFontFamily,
          fontSize: 13,
          height: 18 / 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        const AppCustomTokens(
          heroSurfaceColor: AppColors.lightHeroSurface,
          heroTextColor: AppColors.lightHeroText,
          accentGroceries: AppColors.accentGroceriesLight,
          accentShopping: AppColors.accentShopping,
          accentBills: AppColors.accentBills,
          accentTransport: AppColors.accentTransport,
          accentSavings: AppColors.accentSavings,
          accentAlert: AppColors.accentAlert,
          statusTileTintOpacity: 0.12, // 12% in light mode
          cardBorderRadius: 24.0, // 24-32px radius per spec
          gridUnit: AppSpacing.space2,
          incomeColor: AppColors.accentSavings,
          expenseColor: AppColors.accentAlert,
          goldAccent: AppColors.darkHeroAccentText,
          goldGlow: const Color(0x33FFC64B),
          surfaceGlass: const Color(0x0AFFFFFF),
          borderGlass: const Color(0x26FFFFFF),
          borderGoldRim: const Color(0x33FFC64B),
          textGold: AppColors.darkHeroAccentText,
        ),
      ],
    );
  }
}
