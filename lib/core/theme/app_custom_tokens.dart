import 'package:flutter/material.dart';

class AppCustomTokens extends ThemeExtension<AppCustomTokens> {
  final Color incomeColor;
  final Color expenseColor;
  final Color goldAccent;
  final Color goldGlow;
  final Color surfaceGlass;
  final Color borderGlass;
  final Color borderGoldRim;
  final Color textGold;
  final double cardBorderRadius;
  final double gridUnit;

  const AppCustomTokens({
    required this.incomeColor,
    required this.expenseColor,
    required this.goldAccent,
    required this.goldGlow,
    required this.surfaceGlass,
    required this.borderGlass,
    required this.borderGoldRim,
    required this.textGold,
    required this.cardBorderRadius,
    required this.gridUnit,
  });

  @override
  AppCustomTokens copyWith({
    Color? incomeColor,
    Color? expenseColor,
    Color? goldAccent,
    Color? goldGlow,
    Color? surfaceGlass,
    Color? borderGlass,
    Color? borderGoldRim,
    Color? textGold,
    double? cardBorderRadius,
    double? gridUnit,
  }) {
    return AppCustomTokens(
      incomeColor: incomeColor ?? this.incomeColor,
      expenseColor: expenseColor ?? this.expenseColor,
      goldAccent: goldAccent ?? this.goldAccent,
      goldGlow: goldGlow ?? this.goldGlow,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      borderGlass: borderGlass ?? this.borderGlass,
      borderGoldRim: borderGoldRim ?? this.borderGoldRim,
      textGold: textGold ?? this.textGold,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      gridUnit: gridUnit ?? this.gridUnit,
    );
  }

  @override
  AppCustomTokens lerp(ThemeExtension<AppCustomTokens>? other, double t) {
    if (other is! AppCustomTokens) {
      return this;
    }
    return AppCustomTokens(
      incomeColor: Color.lerp(incomeColor, other.incomeColor, t)!,
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      goldGlow: Color.lerp(goldGlow, other.goldGlow, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      borderGlass: Color.lerp(borderGlass, other.borderGlass, t)!,
      borderGoldRim: Color.lerp(borderGoldRim, other.borderGoldRim, t)!,
      textGold: Color.lerp(textGold, other.textGold, t)!,
      cardBorderRadius: cardBorderRadius + (other.cardBorderRadius - cardBorderRadius) * t,
      gridUnit: gridUnit + (other.gridUnit - gridUnit) * t,
    );
  }
}
