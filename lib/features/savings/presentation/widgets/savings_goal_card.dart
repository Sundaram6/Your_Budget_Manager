import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/widgets/cards/glass_card.dart';
import '../../../../engines/savings/models/savings_goal.dart';
import 'savings_progress_ring.dart';

class SavingsGoalCard extends StatelessWidget {
  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  final SavingsGoalModel goal;
  final VoidCallback onTap;

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(goal.colorHex);
    
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SavingsProgressRing(
            progress: goal.progress,
            color: color,
            child: Icon(Icons.savings, color: color), // Placeholder for dynamic icon
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: context.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${goal.currentAmount.toCurrency()} / ${goal.targetAmount.toCurrencyCompact()}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (goal.daysRemaining != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${goal.daysRemaining} days left',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: goal.daysRemaining! < 7 ? context.colorScheme.error : context.colorScheme.primary,
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (goal.isCompleted)
            Icon(Icons.check_circle, color: context.colorScheme.primary),
        ],
      ),
    );
  }
}
