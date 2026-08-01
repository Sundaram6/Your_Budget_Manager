import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/core/theme/app_colors.dart';
import 'package:your_budget_manager/core/theme/app_custom_tokens.dart';
import 'package:your_budget_manager/core/theme/app_radius.dart';
import 'package:your_budget_manager/core/theme/app_spacing.dart';

void main() {
  group('AppTheme Tests', () {
    test('darkTheme has correct brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('lightTheme has correct brightness', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
    });

    test('Theme contains AppCustomTokens extension', () {
      final theme = AppTheme.darkTheme;
      final tokens = theme.extension<AppCustomTokens>();
      
      expect(tokens, isNotNull);
      expect(tokens!.incomeColor, AppColors.darkIncome);
    });
    
    test('AppCustomTokens copyWith works correctly', () {
      final tokens = const AppCustomTokens(
        incomeColor: Colors.green,
        expenseColor: Colors.red,
        goldAccent: Colors.amber,
        goldGlow: Colors.yellow,
        surfaceGlass: Colors.white10,
        borderGlass: Colors.white24,
        borderGoldRim: Colors.amberAccent,
        textGold: Colors.amber,
        cardBorderRadius: 10,
        gridUnit: 8,
      );
      
      final newTokens = tokens.copyWith(incomeColor: Colors.blue, gridUnit: 16);
      
      expect(newTokens.incomeColor, Colors.blue);
      expect(newTokens.gridUnit, 16);
      expect(newTokens.expenseColor, Colors.red);
    });

    test('AppCustomTokens lerp works correctly', () {
      final tokens1 = const AppCustomTokens(
        incomeColor: Colors.black,
        expenseColor: Colors.black,
        goldAccent: Colors.black,
        goldGlow: Colors.black,
        surfaceGlass: Colors.black,
        borderGlass: Colors.black,
        borderGoldRim: Colors.black,
        textGold: Colors.black,
        cardBorderRadius: 0,
        gridUnit: 0,
      );
      
      final tokens2 = const AppCustomTokens(
        incomeColor: Colors.white,
        expenseColor: Colors.white,
        goldAccent: Colors.white,
        goldGlow: Colors.white,
        surfaceGlass: Colors.white,
        borderGlass: Colors.white,
        borderGoldRim: Colors.white,
        textGold: Colors.white,
        cardBorderRadius: 20,
        gridUnit: 10,
      );
      
      final lerped = tokens1.lerp(tokens2, 0.5);
      
      expect(lerped.incomeColor, const Color(0xFF7F7F7F));
      expect(lerped.cardBorderRadius, 10.0);
      expect(lerped.gridUnit, 5.0);
    });

    test('AppSpacing are multiples of 4', () {
      expect(AppSpacing.space1 % 4, 0);
      expect(AppSpacing.space2 % 4, 0);
      expect(AppSpacing.space3 % 4, 0);
      expect(AppSpacing.space4 % 4, 0);
      expect(AppSpacing.space6 % 4, 0);
      expect(AppSpacing.space8 % 4, 0);
      expect(AppSpacing.space12 % 4, 0);
      expect(AppSpacing.space16 % 4, 0);
    });

    test('AppRadius values are correct', () {
      expect(AppRadius.radiusSm, 8.0);
      expect(AppRadius.radiusMd, 12.0);
      expect(AppRadius.radiusLg, 20.0);
      expect(AppRadius.radiusFull, 9999.0);
    });
  });
}
