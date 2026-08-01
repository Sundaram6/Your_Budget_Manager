import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppElevation {
  static const List<BoxShadow> level0 = [];

  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x80000000), // rgba(0,0,0,0.5)
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x99000000), // rgba(0,0,0,0.6)
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0xCC000000), // rgba(0,0,0,0.8)
      offset: Offset(0, 20),
      blurRadius: 48,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: AppColors.darkGoldGlow,
      offset: Offset(0, 0),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}
