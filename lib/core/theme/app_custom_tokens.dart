import 'package:flutter/material.dart';

class AppCustomTokens extends ThemeExtension<AppCustomTokens> {
  final Color heroSurfaceColor;
  final Color heroTextColor;
  
  final Color accentGroceries;
  final Color accentShopping;
  final Color accentBills;
  final Color accentTransport;
  final Color accentSavings;
  final Color accentAlert;
  
  final double statusTileTintOpacity;
  
  final double cardBorderRadius;
  final double gridUnit;

  // Legacy tokens for backwards compatibility with old screens
  final Color incomeColor;
  final Color expenseColor;
  final Color goldAccent;
  final Color goldGlow;
  final Color surfaceGlass;
  final Color borderGlass;
  final Color borderGoldRim;
  final Color textGold;

  const AppCustomTokens({
    required this.heroSurfaceColor,
    required this.heroTextColor,
    required this.accentGroceries,
    required this.accentShopping,
    required this.accentBills,
    required this.accentTransport,
    required this.accentSavings,
    required this.accentAlert,
    required this.statusTileTintOpacity,
    required this.cardBorderRadius,
    required this.gridUnit,
    required this.incomeColor,
    required this.expenseColor,
    required this.goldAccent,
    required this.goldGlow,
    required this.surfaceGlass,
    required this.borderGlass,
    required this.borderGoldRim,
    required this.textGold,
  });

  static const AppCustomTokens dark = AppCustomTokens(
    heroSurfaceColor: Color(0xFF1E1E1E),
    heroTextColor: Color(0xFFD4AF37),
    accentGroceries: Color(0xFF26A69A),
    accentShopping: Color(0xFFAB47BC),
    accentBills: Color(0xFF42A5F5),
    accentTransport: Color(0xFFFF7043),
    accentSavings: Color(0xFF66BB6A),
    accentAlert: Color(0xFFEF5350),
    statusTileTintOpacity: 0.15,
    cardBorderRadius: 24.0,
    gridUnit: 8.0,
    incomeColor: Color(0xFF66BB6A),
    expenseColor: Color(0xFFEF5350),
    goldAccent: Color(0xFFD4AF37),
    goldGlow: Color(0x33FFC64B),
    surfaceGlass: Color(0x0AFFFFFF),
    borderGlass: Color(0x26FFFFFF),
    borderGoldRim: Color(0x33FFC64B),
    textGold: Color(0xFFD4AF37),
  );

  @override
  AppCustomTokens copyWith({
    Color? heroSurfaceColor,
    Color? heroTextColor,
    Color? accentGroceries,
    Color? accentShopping,
    Color? accentBills,
    Color? accentTransport,
    Color? accentSavings,
    Color? accentAlert,
    double? statusTileTintOpacity,
    double? cardBorderRadius,
    double? gridUnit,
    Color? incomeColor,
    Color? expenseColor,
    Color? goldAccent,
    Color? goldGlow,
    Color? surfaceGlass,
    Color? borderGlass,
    Color? borderGoldRim,
    Color? textGold,
  }) {
    return AppCustomTokens(
      heroSurfaceColor: heroSurfaceColor ?? this.heroSurfaceColor,
      heroTextColor: heroTextColor ?? this.heroTextColor,
      accentGroceries: accentGroceries ?? this.accentGroceries,
      accentShopping: accentShopping ?? this.accentShopping,
      accentBills: accentBills ?? this.accentBills,
      accentTransport: accentTransport ?? this.accentTransport,
      accentSavings: accentSavings ?? this.accentSavings,
      accentAlert: accentAlert ?? this.accentAlert,
      statusTileTintOpacity: statusTileTintOpacity ?? this.statusTileTintOpacity,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      gridUnit: gridUnit ?? this.gridUnit,
      incomeColor: incomeColor ?? this.incomeColor,
      expenseColor: expenseColor ?? this.expenseColor,
      goldAccent: goldAccent ?? this.goldAccent,
      goldGlow: goldGlow ?? this.goldGlow,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      borderGlass: borderGlass ?? this.borderGlass,
      borderGoldRim: borderGoldRim ?? this.borderGoldRim,
      textGold: textGold ?? this.textGold,
    );
  }

  @override
  AppCustomTokens lerp(ThemeExtension<AppCustomTokens>? other, double t) {
    if (other is! AppCustomTokens) {
      return this;
    }
    return AppCustomTokens(
      heroSurfaceColor: Color.lerp(heroSurfaceColor, other.heroSurfaceColor, t)!,
      heroTextColor: Color.lerp(heroTextColor, other.heroTextColor, t)!,
      accentGroceries: Color.lerp(accentGroceries, other.accentGroceries, t)!,
      accentShopping: Color.lerp(accentShopping, other.accentShopping, t)!,
      accentBills: Color.lerp(accentBills, other.accentBills, t)!,
      accentTransport: Color.lerp(accentTransport, other.accentTransport, t)!,
      accentSavings: Color.lerp(accentSavings, other.accentSavings, t)!,
      accentAlert: Color.lerp(accentAlert, other.accentAlert, t)!,
      statusTileTintOpacity: statusTileTintOpacity + (other.statusTileTintOpacity - statusTileTintOpacity) * t,
      cardBorderRadius: cardBorderRadius + (other.cardBorderRadius - cardBorderRadius) * t,
      gridUnit: gridUnit + (other.gridUnit - gridUnit) * t,
      incomeColor: Color.lerp(incomeColor, other.incomeColor, t)!,
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      goldGlow: Color.lerp(goldGlow, other.goldGlow, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      borderGlass: Color.lerp(borderGlass, other.borderGlass, t)!,
      borderGoldRim: Color.lerp(borderGoldRim, other.borderGoldRim, t)!,
      textGold: Color.lerp(textGold, other.textGold, t)!,
    );
  }
}
