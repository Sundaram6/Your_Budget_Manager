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
    final activeInsight = topInsight ?? AiInsight(
      id: 'default_tip',
      title: 'Welcome to Your Budget Manager',
      description: 'Start tracking expenses to see personalized insights.',
      type: InsightType.tip,
      generatedAt: DateTime.now(),
      priority: 5,
    );

    final borderColor = _getInsightColor(activeInsight.type);

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
                          value: healthScore <= 0 ? 0.0 : (healthScore / 100).clamp(0.0, 1.0),
                          backgroundColor: AppColors.darkSurface3,
                          valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(healthScore)),
                          strokeWidth: 4,
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$healthScore',
                            style: TextStyle(
                              color: _getScoreColor(healthScore),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

          Row(
            children: [
              Icon(_getInsightIcon(activeInsight.type), color: borderColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  activeInsight.title.isNotEmpty ? activeInsight.title : 'Welcome to Your Budget Manager',
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            activeInsight.description.isNotEmpty ? activeInsight.description : 'Start tracking expenses to see personalized insights.',
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.darkIncome;
    if (score >= 50) return Colors.amber;
    if (score >= 0) return Colors.orange;
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
