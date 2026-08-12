import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../routing/route_names.dart';

class HeroBalanceCard extends StatelessWidget {
  final int totalBalance; // Integer paise
  
  const HeroBalanceCard({
    super.key,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.gridUnit * 3),
      decoration: BoxDecoration(
        color: tokens.heroSurfaceColor,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: tokens.heroSurfaceColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'THIS MONTH\'S SPEND',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: tokens.heroTextColor.withOpacity(0.7),
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: tokens.heroTextColor.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: tokens.gridUnit),
          Text(
            CurrencyFormatter.formatPaise(totalBalance),
            style: theme.textTheme.displayLarge?.copyWith(
              color: tokens.heroTextColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: tokens.gridUnit * 2),
          Row(
            children: [
              _buildPillAction(context, Icons.add, 'Add Money', tokens, () => context.pushNamed(RouteNames.addTransaction)),
              SizedBox(width: tokens.gridUnit),
              _buildPillAction(context, Icons.arrow_upward, 'Transfer', tokens, () => context.pushNamed(RouteNames.addTransaction)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPillAction(BuildContext context, IconData icon, String label, AppCustomTokens tokens, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.gridUnit * 1.5,
            vertical: tokens.gridUnit,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: tokens.heroTextColor, size: 16),
              SizedBox(width: tokens.gridUnit / 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.heroTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
