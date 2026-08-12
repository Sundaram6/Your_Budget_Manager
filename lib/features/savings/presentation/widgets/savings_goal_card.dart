import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../database/app_database.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentPaise = goal.currentAmount;
    final targetPaise = goal.targetAmount;
    final ratio = targetPaise > 0 ? (currentPaise / targetPaise).clamp(0.0, 1.0) : 0.0;
    final pct = (ratio * 100).round();

    int? daysLeft;
    if (goal.deadline != null) {
      final now = DateTime.now();
      final deadlineDate = DateTime.fromMillisecondsSinceEpoch(goal.deadline!);
      daysLeft = deadlineDate.difference(now).inDays;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkSurface3),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: ratio,
                            backgroundColor: AppColors.darkSurface3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goal.status == 'completed' ? Colors.green : AppColors.darkGoldPrimary,
                            ),
                            strokeWidth: 5,
                          ),
                        ),
                        Icon(
                          _getGoalIcon(goal.iconName),
                          size: 22,
                          color: AppColors.darkGoldPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal.name,
                                style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                              ),
                              Text(
                                '$pct%',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.darkGoldPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyFormatter.formatPaiseNoDecimals(currentPaise)} / ${CurrencyFormatter.formatPaiseNoDecimals(targetPaise)}',
                            style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                          ),
                          if (daysLeft != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              daysLeft >= 0 ? '$daysLeft days left' : 'Deadline passed',
                              style: AppTypography.caption.copyWith(
                                color: daysLeft < 7 ? AppColors.darkExpense : AppColors.darkIncome,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (goal.autoDeduct && goal.autoDeductAmount != null) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Auto-deduct: ${CurrencyFormatter.formatPaiseNoDecimals(goal.autoDeductAmount!)}/month',
                      style: AppTypography.caption.copyWith(color: AppColors.darkIncome, fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(String iconName) {
    switch (iconName) {
      case 'emergency':
        return Icons.healing;
      case 'phone':
        return Icons.phone_iphone;
      case 'car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'flight':
        return Icons.flight_takeoff;
      case 'school':
        return Icons.school;
      default:
        return Icons.savings;
    }
  }
}
