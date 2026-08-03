import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../engines/intelligence/intelligence_engine_provider.dart';
import '../../../../engines/intelligence/models/ai_insight.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  List<AiInsight> _insights = [];
  int _healthScore = 100;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final engine = ref.read(intelligenceEngineProvider);
    final insights = await engine.generateInsights();
    final score = await engine.calculateBudgetHealthScore();
    if (mounted) {
      setState(() {
        _insights = insights;
        _healthScore = score;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Financial Insights'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  // Health Score Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: _healthScore / 100,
                                backgroundColor: AppColors.darkSurface3,
                                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(_healthScore)),
                                strokeWidth: 6,
                              ),
                            ),
                            Text(
                              '$_healthScore',
                              style: AppTypography.heading3.copyWith(
                                color: _getScoreColor(_healthScore),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget Health Score',
                                style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getScoreLabel(_healthScore),
                                style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space6),

                  Text(
                    'Active Insights',
                    style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                  ),
                  const SizedBox(height: AppSpacing.space3),

                  if (_insights.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.space6),
                        child: Column(
                          children: [
                            const Icon(Icons.auto_awesome_outlined, size: 64, color: AppColors.darkTextSecondary),
                            const SizedBox(height: AppSpacing.space3),
                            Text(
                              'No insights yet. Start tracking expenses!',
                              style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._insights.map((insight) {
                      final borderBorderColor = _getInsightColor(insight.type);
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                        padding: const EdgeInsets.all(AppSpacing.space4),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(color: borderBorderColor, width: 5),
                            top: const BorderSide(color: AppColors.darkSurface3),
                            right: const BorderSide(color: AppColors.darkSurface3),
                            bottom: const BorderSide(color: AppColors.darkSurface3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(_getInsightIcon(insight.type), color: borderBorderColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    insight.title,
                                    style: AppTypography.heading3.copyWith(
                                      color: AppColors.darkTextPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              insight.description,
                              style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd MMM yyyy, hh:mm a').format(insight.generatedAt),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.darkTextSecondary.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.darkIncome;
    if (score >= 70) return Colors.amber;
    if (score >= 50) return Colors.orange;
    return AppColors.darkExpense;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent — spending and saving on track!';
    if (score >= 70) return 'Good — staying within target range.';
    if (score >= 50) return 'Fair — approaching your monthly budget limit.';
    return 'Poor — budget exceeded or no savings set up.';
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
