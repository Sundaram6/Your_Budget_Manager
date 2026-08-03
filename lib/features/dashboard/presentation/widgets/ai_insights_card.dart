import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../engines/intelligence/models/ai_insight.dart';

class AiInsightsCard extends StatelessWidget {
  final int healthScore;
  final AiInsight? topInsight;

  const AiInsightsCard({
    super.key,
    required this.healthScore,
    this.topInsight,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = topInsight != null ? _getInsightColor(topInsight!.type) : AppColors.darkGoldPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: borderColor, width: 5),
          top: const BorderSide(color: AppColors.darkSurface3),
          right: const BorderSide(color: AppColors.darkSurface3),
          bottom: const BorderSide(color: AppColors.darkSurface3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: CircularProgressIndicator(
                          value: (healthScore / 100).clamp(0.0, 1.0),
                          backgroundColor: AppColors.darkSurface3,
                          valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(healthScore)),
                          strokeWidth: 4,
                        ),
                      ),
                      Text(
                        '$healthScore',
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Advisor',
                        style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                      ),
                      Text(
                        'Budget Health',
                        style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/insights'),
                child: Text(
                  'See All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.darkGoldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),

          if (topInsight != null) ...[
            Row(
              children: [
                Icon(_getInsightIcon(topInsight!.type), color: borderColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    topInsight!.title,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              topInsight!.description,
              style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
            ),
          ] else ...[
            Text(
              'Log transactions to receive personalized AI financial insights.',
              style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.darkIncome;
    if (score >= 70) return Colors.amber;
    if (score >= 50) return Colors.orange;
    return AppColors.darkExpense;
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.warning:
        return AppColors.darkExpense;
      case InsightType.tip:
        return AppColors.darkGoldPrimary;
      case InsightType.achievement:
        return AppColors.darkIncome;
      case InsightType.suggestion:
        return Colors.blueAccent;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.warning:
        return Icons.warning_amber_rounded;
      case InsightType.tip:
        return Icons.lightbulb_outline;
      case InsightType.achievement:
        return Icons.emoji_events_outlined;
      case InsightType.suggestion:
        return Icons.auto_awesome;
    }
  }
}
