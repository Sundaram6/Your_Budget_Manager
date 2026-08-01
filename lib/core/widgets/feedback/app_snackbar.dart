import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_elevation.dart';

enum SnackbarType { success, error, info }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = AppColors.darkSurface2;
        icon = Icons.check_circle;
        iconColor = AppColors.darkIncome;
        break;
      case SnackbarType.error:
        backgroundColor = AppColors.darkSurface2;
        icon = Icons.error;
        iconColor = AppColors.darkExpense;
        break;
      case SnackbarType.info:
      default:
        backgroundColor = AppColors.darkSurface2;
        icon = Icons.info;
        iconColor = AppColors.darkGoldPrimary;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadius.md,
            border: Border.all(color: AppColors.darkBorderMedium),
            boxShadow: AppElevation.level2,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyBase.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
