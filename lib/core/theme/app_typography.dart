import 'dart:ui';
import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamilyDisplay = 'Syne';
  static const String fontFamilyBody = 'Inter';

  static const TextStyle displayXL = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 48,
    height: 56 / 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -48 * 0.03,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -32 * 0.02,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -24 * 0.015,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -18 * 0.01,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -16 * 0.005,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle bodyBase = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 12 * 0.02,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle microTag = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 10 * 0.05,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
