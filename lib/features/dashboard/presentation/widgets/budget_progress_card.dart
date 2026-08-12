import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../database/app_database.dart';

class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final int spentAmount; // Integer paise
  final int savingsAllocationsPaise; // Integer paise

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.spentAmount,
    this.savingsAllocationsPaise = 0,
  });

  @override
  Widget build(BuildContext context) {
    final budgetAmountPaise = budget.amount;
    final ratio = budgetAmountPaise > 0 ? (spentAmount / budgetAmountPaise) : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);

    int percentage;
    if (spentAmount > 0 && ratio > 0) {
      percentage = max(1, (ratio * 100).round());
    } else {
      percentage = 0;
    }

    final isOverBudget = spentAmount > budgetAmountPaise;
    final overAmountPaise = isOverBudget ? (spentAmount - budgetAmountPaise) : 0;
    final remainingPaise = max(0, budgetAmountPaise - spentAmount);
    final spendablePaise = max(0, budgetAmountPaise - savingsAllocationsPaise - spentAmount);

    final progressColor = _getProgressColor(ratio);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget ? AppColors.darkExpense : AppColors.darkSurface3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budget: ${CurrencyFormatter.formatPaiseNoDecimals(budgetAmountPaise)}',
                style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
              ),
              Text(
                '$percentage%',
                style: AppTypography.caption.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clampedRatio,
              minHeight: 10,
              backgroundColor: AppColors.darkSurface3,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: AppSpacing.space2),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyFormatter.formatPaise(spentAmount)}',
                style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
              ),
              Text(
                savingsAllocationsPaise > 0
                    ? 'Spendable: ${CurrencyFormatter.formatPaise(spendablePaise)}'
                    : 'Remaining: ${CurrencyFormatter.formatPaise(remainingPaise)}',
                style: AppTypography.caption.copyWith(
                  color: savingsAllocationsPaise > 0 ? AppColors.darkGoldPrimary : AppColors.darkTextSecondary,
                  fontWeight: savingsAllocationsPaise > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),

          if (savingsAllocationsPaise > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings: ${CurrencyFormatter.formatPaise(savingsAllocationsPaise)}',
                  style: AppTypography.caption.copyWith(color: AppColors.darkIncome),
                ),
                Text(
                  'Total Remaining: ${CurrencyFormatter.formatPaise(remainingPaise)}',
                  style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary, fontSize: 11),
                ),
              ],
            ),
          ],

          if (isOverBudget) ...[
            const SizedBox(height: AppSpacing.space3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space2),
              decoration: BoxDecoration(
                color: AppColors.darkExpense.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You\'ve exceeded your ${CurrencyFormatter.formatPaiseNoDecimals(budgetAmountPaise)} budget by ${CurrencyFormatter.formatPaise(overAmountPaise)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.darkExpense,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(double ratio) {
    if (ratio >= 1.0) return AppColors.darkExpense;
    if (ratio >= 0.8) return Colors.orange;
    if (ratio >= 0.5) return Colors.amber;
    return AppColors.darkIncome;
  }
}
