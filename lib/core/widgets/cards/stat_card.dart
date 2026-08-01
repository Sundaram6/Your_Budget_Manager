import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import 'glass_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final double? trend;
  final Widget? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: const IconThemeData(
                    color: AppColors.darkTextTertiary,
                    size: 16,
                  ),
                  child: icon!,
                ),
                const SizedBox(width: AppSpacing.space2),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            value,
            style: AppTypography.heading2.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.space1),
            Row(
              children: [
                Icon(
                  trend! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: trend! >= 0 ? AppColors.darkIncome : AppColors.darkExpense,
                ),
                const SizedBox(width: AppSpacing.space1),
                Text(
                  '${trend!.abs().toStringAsFixed(1)}%',
                  style: AppTypography.microTag.copyWith(
                    color: trend! >= 0 ? AppColors.darkIncome : AppColors.darkExpense,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
