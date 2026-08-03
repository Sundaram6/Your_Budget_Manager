import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../engines/budget/models/daily_allowance.dart';

class DailyAllowanceCard extends StatelessWidget {
  final DailyAllowance allowance;

  const DailyAllowanceCard({super.key, required this.allowance});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    final color = allowance.isOverBudget ? AppColors.darkExpense : AppColors.darkIncome;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space3,
        horizontal: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            allowance.isOverBudget ? Icons.warning_amber_rounded : Icons.account_balance_wallet_outlined,
            color: color,
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              allowance.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
