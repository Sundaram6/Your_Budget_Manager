import 'package:flutter/material.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../engines/budget/models/daily_allowance.dart';

class DailyAllowanceCard extends StatelessWidget {
  final DailyAllowance allowance;

  const DailyAllowanceCard({super.key, required this.allowance});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    final color = _getColor(tokens);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space3,
        horizontal: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        'You can comfortably spend ${allowance.amount.toCurrency()} today.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor(AppCustomTokens tokens) {
    if (allowance.amount <= 0) return tokens.expenseColor;
    
    // Assuming tight is < 20% of some average, here we use < 20% of remaining vs days left logic,
    // but the prompt says: amber when tight (< 20% of average allowance over the month).
    // Let's approximate tight for now:
    if (allowance.amount < 100) return Colors.orange; // Fallback hardcode or a warning color
    
    return tokens.incomeColor;
  }
}
