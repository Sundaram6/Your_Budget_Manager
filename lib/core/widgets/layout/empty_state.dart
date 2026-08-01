import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? lottieAsset;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (lottieAsset != null) ...[
            Lottie.asset(
              lottieAsset!,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              animate: !MediaQuery.disableAnimationsOf(context),
            ),
            const SizedBox(height: AppSpacing.space6),
          ],
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
