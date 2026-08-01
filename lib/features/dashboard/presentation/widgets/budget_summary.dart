import 'package:flutter/material.dart';

import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../engines/budget/models/budget_progress.dart';

class BudgetSummaryWidget extends StatelessWidget {
  final List<BudgetProgress> budgets;

  const BudgetSummaryWidget({super.key, required this.budgets});

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        child: Text('No active budgets.'),
      );
    }
    
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: budgets.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.space3),
        itemBuilder: (context, index) {
          final b = budgets[index];
          return _BudgetCard(progress: b);
        },
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetProgress progress;

  const _BudgetCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: tokens.surfaceGlass,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        border: Border.all(color: progress.isOverBudget ? tokens.expenseColor : tokens.borderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget', // Ideally category name, but Progress doesn't have it unless extended.
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            '${progress.spent.toCurrency()} / ${progress.limit.toCurrency()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.limit > 0 ? (progress.spent / progress.limit).clamp(0.0, 1.0) : 0,
            backgroundColor: tokens.borderGlass,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress.isOverBudget ? tokens.expenseColor : tokens.incomeColor,
            ),
          ),
        ],
      ),
    );
  }
}
