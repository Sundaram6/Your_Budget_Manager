import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../database/app_database.dart';

class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final double spentAmount;
  final double savingsAllocationsRupees;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.spentAmount,
    this.savingsAllocationsRupees = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final budgetAmountRupees = budget.amount / 100;
    final ratio = budgetAmountRupees > 0 ? (spentAmount / budgetAmountRupees) : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);

    int percentage;
    if (spentAmount > 0 && ratio > 0) {
      percentage = max(1, (ratio * 100).round());
    } else {
      percentage = 0;
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final currencyFormatNoDecimals = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final isOverBudget = spentAmount > budgetAmountRupees;
    final overAmountRupees = isOverBudget ? (spentAmount - budgetAmountRupees) : 0.0;
    final remainingRupees = (budgetAmountRupees - spentAmount).clamp(0.0, double.infinity);
    final spendableRupees = (budgetAmountRupees - savingsAllocationsRupees - spentAmount).clamp(0.0, double.infinity);

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
                'Monthly Budget: ${currencyFormatNoDecimals.format(budgetAmountRupees)}',
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
                'Spent: ${currencyFormat.format(spentAmount)}',
                style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
              ),
              Text(
                savingsAllocationsRupees > 0
                    ? 'Spendable: ${currencyFormat.format(spendableRupees)}'
                    : 'Remaining: ${currencyFormat.format(remainingRupees)}',
                style: AppTypography.caption.copyWith(
                  color: savingsAllocationsRupees > 0 ? AppColors.darkGoldPrimary : AppColors.darkTextSecondary,
                  fontWeight: savingsAllocationsRupees > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),

          if (savingsAllocationsRupees > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings: ${currencyFormat.format(savingsAllocationsRupees)}',
                  style: AppTypography.caption.copyWith(color: AppColors.darkIncome),
                ),
                Text(
                  'Total Remaining: ${currencyFormat.format(remainingRupees)}',
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
                'You\'ve exceeded your ${currencyFormatNoDecimals.format(budgetAmountRupees)} budget by ${currencyFormat.format(overAmountRupees)}',
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
