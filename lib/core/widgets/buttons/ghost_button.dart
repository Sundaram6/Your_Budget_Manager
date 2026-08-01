import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class GhostButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;

  const GhostButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading || onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.full,
        onTap: disabled ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkTextPrimary),
                  ),
                )
              else if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: disabled ? AppColors.darkTextTertiary : AppColors.darkTextPrimary,
                    size: 18,
                  ),
                  child: icon!,
                ),
                const SizedBox(width: AppSpacing.space2),
              ],
              if (!isLoading)
                Text(
                  label,
                  style: AppTypography.bodyBase.copyWith(
                    color: disabled ? AppColors.darkTextTertiary : AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
