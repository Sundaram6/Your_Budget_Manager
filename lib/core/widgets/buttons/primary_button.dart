import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
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

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: AppRadius.full,
        gradient: disabled
            ? const LinearGradient(colors: [AppColors.darkSurface3, AppColors.darkSurface3])
            : const LinearGradient(
                colors: [AppColors.darkGoldLight, AppColors.darkGoldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: disabled
            ? []
            : const [
                BoxShadow(
                  color: AppColors.darkGoldGlow,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.full,
          onTap: disabled ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkCanvas),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: disabled ? AppColors.darkTextTertiary : AppColors.darkCanvas,
                            size: 20,
                          ),
                          child: icon!,
                        ),
                        const SizedBox(width: AppSpacing.space2),
                      ],
                      Text(
                        label,
                        style: AppTypography.bodyLg.copyWith(
                          color: disabled ? AppColors.darkTextTertiary : AppColors.darkCanvas,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
