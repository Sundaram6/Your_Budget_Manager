import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../engines/intelligence/models/ai_insight.dart';

/// A bold, high-contrast card surfacing the top-priority AI insight.
/// Shown only when insights are non-empty. Tap navigates to /insights.
class HighlightCard extends StatelessWidget {
  final AiInsight insight;

  const HighlightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Bold dark card in both themes for strong visual contrast.
    final cardColor = isDark ? AppColors.darkSurface2 : AppColors.darkSurface1;
    const textColor = AppColors.darkTextPrimary;
    const subtextColor = AppColors.darkTextSecondary;

    final IconData iconData;
    switch (insight.type) {
      case InsightType.warning:
        iconData = PhosphorIcons.warningDiamondFill;
        break;
      case InsightType.achievement:
        iconData = PhosphorIcons.trophyFill;
        break;
      case InsightType.suggestion:
        iconData = PhosphorIcons.sparkleFill;
        break;
      case InsightType.tip:
      default:
        iconData = PhosphorIcons.lightbulbFill;
        break;
    }

    return GestureDetector(
      onTap: () => context.push('/insights'),
      child: Container(
        key: const ValueKey('highlight_card'),
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar in heroTextColor (gold in dark)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: tokens.heroTextColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(tokens.cardBorderRadius),
                    bottomLeft: Radius.circular(tokens.cardBorderRadius),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(iconData, color: tokens.heroTextColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: AppTypography.sectionHeader.copyWith(
                                color: textColor,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (insight.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                insight.description,
                                style: AppTypography.bodyRegular.copyWith(
                                  color: subtextColor,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        PhosphorIcons.caretRight,
                        color: subtextColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
