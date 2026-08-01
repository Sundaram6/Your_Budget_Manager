import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_elevation.dart';
import '../../theme/app_radius.dart';

class GoldCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  const GoldCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.darkBorderGoldRim,
          width: 1.5,
        ),
        boxShadow: AppElevation.level3,
      ),
      child: child,
    );
  }
}
