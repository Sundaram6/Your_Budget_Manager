import 'package:flutter/material.dart';


import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? lottieAsset;
  final IconData? icon;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.lottieAsset,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final displayIcon = icon ?? Icons.inbox_outlined;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.darkSurface2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              displayIcon,
              size: 48,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          Text(
            title,
            style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.space2),
            Text(
              subtitle!,
              style: AppTypography.bodyBase.copyWith(color: AppColors.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}


