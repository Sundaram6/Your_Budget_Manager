import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/charts/progress_donut_chart.dart';
import '../../../../engines/analytics/analytics_engine_provider.dart';
import '../../../../engines/analytics/models/analytics_models.dart';
import '../../../../engines/intelligence/intelligence_engine_provider.dart';
import '../../../../engines/intelligence/models/ai_insight.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  List<AiInsight> _insights = [];
  List<CategoryBreakdown> _categoryBreakdown = [];
  int _healthScore = 100;
  bool _isLoading = true;
  int _selectedSegment = 0; // 0 for Categories, 1 for AI Insights

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final intelligenceEngine = ref.read(intelligenceEngineProvider);
    final analyticsEngine = ref.read(analyticsEngineProvider);
    
    final insights = await intelligenceEngine.generateInsights();
    final score = await intelligenceEngine.calculateBudgetHealthScore();
    
    final now = DateTime.now();
    final breakdown = await analyticsEngine.getCategoryBreakdown(now.year, now.month);
    
    if (mounted) {
      setState(() {
        _insights = insights;
        _healthScore = score;
        _categoryBreakdown = breakdown;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Analytics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  _buildSegmentedControl(context, tokens),
                  const SizedBox(height: AppSpacing.space5),
                  
                  if (_selectedSegment == 0) ...[
                    _buildCategoryDonut(context, tokens),
                    const SizedBox(height: AppSpacing.space5),
                    _buildLegendChips(context, tokens),
                  ] else ...[
                    _buildHealthScoreCard(context, tokens),
                    const SizedBox(height: AppSpacing.space5),
                    ..._buildInsightsList(context, tokens),
                  ],
                  const SizedBox(height: 80), // bottom padding
                ].animate(interval: 50.ms).fade(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad),
              ),
            ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context, AppCustomTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedSegment == 0 ? tokens.accentTransport : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Spending',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _selectedSegment == 0 ? tokens.heroTextColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedSegment == 1 ? tokens.accentSavings : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _selectedSegment == 1 ? tokens.heroTextColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDonut(BuildContext context, AppCustomTokens tokens) {
    if (_categoryBreakdown.isEmpty) {
      return const Center(child: Text('No spending data for this month.'));
    }

    final data = <String, double>{};
    final colors = <Color>[];
    
    // Sort by amount descending
    final sortedBreakdown = List<CategoryBreakdown>.from(_categoryBreakdown)
      ..sort((a, b) => b.total.compareTo(a.total));

    int totalPaise = 0;
    final predefinedColors = [
      tokens.accentShopping,
      tokens.accentTransport,
      tokens.accentBills,
      tokens.accentSavings,
      tokens.accentAlert,
    ];

    for (int i = 0; i < sortedBreakdown.length; i++) {
      final cb = sortedBreakdown[i];
      data[cb.categoryName] = cb.total / 100.0;
      totalPaise += cb.total;
      colors.add(predefinedColors[i % predefinedColors.length]);
    }

    return Container(
      padding: EdgeInsets.all(tokens.gridUnit * 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
      ),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: ProgressDonutChart(
          data: data,
          colors: colors,
          strokeWidth: 24,
          centerRadius: 80,
          centerWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.formatPaiseCompact(totalPaise),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendChips(BuildContext context, AppCustomTokens tokens) {
    final predefinedColors = [
      tokens.accentShopping,
      tokens.accentTransport,
      tokens.accentBills,
      tokens.accentSavings,
      tokens.accentAlert,
    ];

    final sortedBreakdown = List<CategoryBreakdown>.from(_categoryBreakdown)
      ..sort((a, b) => b.total.compareTo(a.total));

    return Wrap(
      spacing: AppSpacing.space2,
      runSpacing: AppSpacing.space2,
      children: List.generate(sortedBreakdown.length, (index) {
        final cb = sortedBreakdown[index];
        final color = predefinedColors[index % predefinedColors.length];
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                cb.categoryName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                CurrencyFormatter.formatPaiseCompact(cb.total),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, AppCustomTokens tokens) {
    Color getScoreColor(int score) {
      if (score >= 90) return tokens.accentSavings;
      if (score >= 70) return tokens.accentTransport;
      if (score >= 50) return tokens.accentShopping;
      return tokens.accentAlert;
    }

    final scoreColor = getScoreColor(_healthScore);

    return Container(
      padding: EdgeInsets.all(tokens.gridUnit * 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scoreColor.withOpacity(0.2), width: 8),
            ),
            child: Center(
              child: Text(
                '$_healthScore',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Health',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _healthScore >= 70 ? 'You are on track. Keep it up!' : 'Action required to balance budget.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildInsightsList(BuildContext context, AppCustomTokens tokens) {
    if (_insights.isEmpty) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.space6),
            child: Text('No insights yet. Start tracking expenses!'),
          ),
        )
      ];
    }

    return _insights.map((insight) {
      final isWarning = insight.type == InsightType.warning;
      final color = isWarning ? tokens.accentAlert : tokens.accentTransport;
      final icon = isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.space3),
        padding: EdgeInsets.all(tokens.gridUnit * 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title.isNotEmpty ? insight.title : 'Insight',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
