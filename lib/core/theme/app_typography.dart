import 'package:flutter/material.dart';

class AppTypography {
  // Existing body font — keeps all other app screens unchanged.
  static const String fontFamily = 'PlusJakartaSans';

  // New premium font pair for the dashboard redesign.
  static const String cabinetFontFamily = 'CabinetGrotesk';
  static const String satoshiFontFamily = 'Satoshi';

  // ─── Cabinet Grotesk styles ────────────────────────────────────────────────

  /// Hero balance figure (~48sp). Use this directly — do NOT use displayLarge
  /// from TextTheme for this size; displayLarge is 44sp for general screens.
  static const TextStyle heroBalance = TextStyle(
    fontFamily: cabinetFontFamily,
    fontSize: 48,
    height: 52 / 48,
    fontWeight: FontWeight.w800, // ExtraBold
    letterSpacing: -48 * 0.03,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Section headers on the dashboard (18–20sp).
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: cabinetFontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -18 * 0.01,
  );

  // ─── Satoshi styles ────────────────────────────────────────────────────────

  /// Body copy on dashboard rows and descriptions (15sp).
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: satoshiFontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// Button labels and emphasis text (14sp, Bold).
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: satoshiFontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  /// Stat tile values on the dashboard (20sp, Bold Cabinet Grotesk).
  static const TextStyle statValue = TextStyle(
    fontFamily: cabinetFontFamily,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -20 * 0.02,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle displayXL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    height: 52 / 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -44 * 0.03,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -32 * 0.02,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -24 * 0.015,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -18 * 0.01,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle bodyBase = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 12 * 0.02,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle microTag = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 10 * 0.1, // Generous spacing for all-caps
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
