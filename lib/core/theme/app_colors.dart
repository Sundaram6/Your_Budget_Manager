import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode - "Dark Jewel Tone"
  static const Color darkCanvas = Color(0xFF15151F);
  static const Color darkSurface1 = Color(0xFF1E1E2C);
  static const Color darkSurface2 = Color(0xFF2A2A3D);

  static const Color darkTextPrimary = Color(0xFFF2F1F7);
  static const Color darkTextSecondary = Color(0xFF8B8AA0);
  
  static const Color darkHeroSurface = Color(0xFF1E1E2C);
  static const Color darkHeroAccentText = Color(0xFFFFC64B); // The old CRED gold

  // Light Mode - "Friendly Pastel"
  static const Color lightCanvas = Color(0xFFF5F3FF);
  static const Color lightSurface1 = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF8F9FA); // Very light grey for nested elements

  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B80);
  
  static const Color lightHeroSurface = Color(0xFF171730);
  static const Color lightHeroText = Color(0xFFFFFFFF);

  // Category Accents (Dual Theme where needed)
  static const Color accentGroceriesLight = Color(0xFF4ECDC4);
  static const Color accentGroceriesDark = Color(0xFF3DDC97);
  
  static const Color accentShopping = Color(0xFFFF9F5A);
  static const Color accentBills = Color(0xFFFFC64B);
  static const Color accentTransport = Color(0xFF5B9BFF);
  static const Color accentSavings = Color(0xFF3DDC97);
  static const Color accentAlert = Color(0xFFFF6B9D);

  // Legacy/Standard Semantic Fallbacks for backwards compatibility during transition
  static const Color darkIncome = accentSavings;
  static const Color darkExpense = accentAlert;
  static const Color lightIncome = accentSavings;
  static const Color lightExpense = accentAlert;
  static const Color darkBorderGlass = Color(0x26FFFFFF);
}
