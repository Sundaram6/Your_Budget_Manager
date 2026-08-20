import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_typography.dart';
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: tokens.heroSurfaceColor,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: tokens.heroSurfaceColor.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top label + icon row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'THIS MONTH\'S SPEND',
                  style: AppTypography.buttonLabel.copyWith(
                    color: tokens.heroTextColor.withOpacity(0.65),
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                PhosphorIcons.wallet,
                color: tokens.heroTextColor.withOpacity(0.45),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hero balance figure � Cabinet Grotesk ExtraBold 48sp
          Text(
            CurrencyFormatter.formatPaise(totalBalance),
            style: AppTypography.heroBalance.copyWith(
              color: tokens.heroTextColor,
            ),
          ),
          const SizedBox(height: 20),

          // Subtle divider between balance and action buttons
          Divider(
            color: tokens.heroTextColor.withOpacity(0.12),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // Pill action buttons � Satoshi Bold, 44dp min height
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPillAction(
                context,
                PhosphorIcons.arrowCircleUpFill,
                'Add Debit',
                tokens,
                () => context.pushNamed(
                  RouteNames.addTransaction,
                  queryParameters: {'type': 'debit'},
                ),
              ),
              _buildPillAction(
                context,
                PhosphorIcons.arrowCircleDownFill,
                'Add Credit',
                tokens,
                () => context.pushNamed(
                  RouteNames.addTransaction,
                  queryParameters: {'type': 'credit'},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillAction(
    BuildContext context,
    IconData icon,
    String label,
    AppCustomTokens tokens,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: tokens.heroTextColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.buttonLabel.copyWith(
                  color: tokens.heroTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
