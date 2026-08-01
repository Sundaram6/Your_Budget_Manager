import 'package:flutter/material.dart';

import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';

class TotalSpendCard extends StatelessWidget {
  final double totalSpend;

  const TotalSpendCard({super.key, required this.totalSpend});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: tokens.surfaceGlass,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        border: Border.all(color: tokens.borderGoldRim),
        boxShadow: [
          BoxShadow(
            color: tokens.goldGlow.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: -4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spend This Month',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            totalSpend.toCurrency(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: tokens.textGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
