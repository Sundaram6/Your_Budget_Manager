import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/dashboard_controller.dart';

/// 2x2 grid of quick-stat tiles displayed below the hero balance card.
/// Pulls only from already-computed [DashboardState] — no new logic.
class QuickStatsRow extends StatelessWidget {
  final DashboardState data;

  const QuickStatsRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;

    // Score band color — mirrors existing health score logic used across the app.
    final Color scoreColor;
    if (data.healthScore >= 80) {
      scoreColor = tokens.accentSavings;
    } else if (data.healthScore >= 50) {
      scoreColor = tokens.accentTransport;
    } else if (data.healthScore >= 0) {
      scoreColor = tokens.accentShopping;
    } else {
      scoreColor = tokens.accentAlert;
    }

    final String scoreBand = data.healthScore >= 80
        ? 'Safe to Spend'
        : data.healthScore >= 50
            ? 'Watch Spending'
            : data.healthScore >= 0
                ? 'Over Budget'
                : 'Critical Deficit';

    final String allowanceLabel;
    final String allowanceSubtitle;
    if (data.dailyAllowance != null) {
      allowanceLabel =
          CurrencyFormatter.formatPaiseCompact(data.dailyAllowance!.amount);
      allowanceSubtitle = data.dailyAllowance!.isOverBudget
          ? 'Over budget'
          : '${data.dailyAllowance!.daysLeft} days left';
    } else {
      allowanceLabel = '—';
      allowanceSubtitle = 'No budget set';
    }

    final String topInsightTitle = data.insights.isNotEmpty
        ? data.insights.first.title
        : 'No insights yet';

    // Use Column + Row to avoid GridView shrinkWrap issues inside ListView.
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: PhosphorIcons.arrowCircleDownFill,
                badgeColor: tokens.accentAlert,
                value: CurrencyFormatter.formatPaiseCompact(data.monthlyTotal),
                label: 'Spent',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                icon: PhosphorIcons.heartbeatFill,
                badgeColor: scoreColor,
                value: '${data.healthScore}',
                label: scoreBand,
                onTap: () => context.push('/insights'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: PhosphorIcons.calendarCheckFill,
                badgeColor: data.dailyAllowance?.isOverBudget == true
                    ? tokens.accentAlert
                    : tokens.accentSavings,
                value: allowanceLabel,
                label: allowanceSubtitle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                icon: PhosphorIcons.lightbulbFill,
                badgeColor: tokens.accentBills,
                value: '',
                label: topInsightTitle,
                onTap: () => context.push('/insights'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color badgeColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.badgeColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
          border: Border.all(color: tokens.borderGlass),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Colored badge circle — 40x40dp
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(tokens.statusTileTintOpacity),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: badgeColor, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            // Text column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value.isNotEmpty)
                    Text(
                      value,
                      style: AppTypography.statValue.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (value.isNotEmpty) const SizedBox(height: 2),
                  Text(
                    label,
                    style: AppTypography.bodyRegular.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}