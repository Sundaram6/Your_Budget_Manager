import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/charts/progress_donut_chart.dart';
import '../../../../engines/analytics/analytics_engine_provider.dart';
import '../../../../engines/analytics/models/analytics_models.dart';
import '../../../../engines/analytics/providers/analytics_customization_provider.dart';
import '../../../../engines/intelligence/intelligence_engine_provider.dart';
import '../../../../engines/intelligence/models/ai_insight.dart';
import '../../../analytics/presentation/widgets/category_filter_dialog.dart';
import '../../../analytics/presentation/widgets/category_transactions_sheet.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _selectedSegment = 0; // 0: Spending, 1: AI Insights
  bool _isLoading = true;
  List<AiInsight> _insights = [];
  int _healthScore = 0;
  List<CategoryBreakdown> _allCategoryBreakdown = [];

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
        _allCategoryBreakdown = breakdown;
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
                  
                  AnimatedSwitcher(
                    duration: AppAnimation.durationNormal,
                    switchInCurve: AppAnimation.curveStandard,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      if (AppAnimation.isReducedMotion(context)) {
                        return child;
                      }
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _selectedSegment == 0
                        ? Column(
                            key: const ValueKey('spending_tab'),
                            children: [
                              _buildCategoryDonut(context, tokens),
                              const SizedBox(height: AppSpacing.space5),
                              _buildLegendChips(context, tokens),
                            ],
                          )
                        : Column(
                            key: const ValueKey('insights_tab'),
                            children: [
                              _buildHealthScoreCard(context, tokens),
                              const SizedBox(height: AppSpacing.space5),
                              ..._buildInsightsList(context, tokens),
                            ],
                          ),
                  ),
                  const SizedBox(height: 80), // bottom padding
                ],
              ),
            ),
    );
  }

  Widget _buildSegmentedControl(BuildContext context, AppCustomTokens tokens) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeBgColor = isDark ? AppColors.darkGoldPrimary : AppColors.lightHeroSurface;
    final activeTextColor = isDark ? Colors.black : Colors.white;
    final inactiveTextColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark ? AppColors.darkBorderGlass : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 0),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedSegment == 0 ? activeBgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Spending',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _selectedSegment == 0 ? activeTextColor : inactiveTextColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 1),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedSegment == 1 ? activeBgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AI Insights',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _selectedSegment == 1 ? activeTextColor : inactiveTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<CategoryBreakdown> _getVisibleBreakdown(Set<String> hiddenCategories) {
    if (_allCategoryBreakdown.isEmpty) return [];
    
    final visible = _allCategoryBreakdown
        .where((cb) => !hiddenCategories.contains(cb.categoryId))
        .toList();
        
    final totalVisible = visible.fold<int>(0, (sum, cb) => sum + cb.total);
    if (totalVisible == 0) return [];
    
    return visible.map((cb) {
      return CategoryBreakdown(
        categoryId: cb.categoryId,
        categoryName: cb.categoryName,
        color: cb.color,
        icon: cb.icon,
        total: cb.total,
        percentage: (cb.total / totalVisible) * 100,
      );
    }).toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  Widget _buildCategoryDonut(BuildContext context, AppCustomTokens tokens) {
    if (_allCategoryBreakdown.isEmpty) {
      return Container(
        padding: EdgeInsets.all(tokens.gridUnit * 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('No spending data for this month.'),
          ),
        ),
      );
    }

    final hiddenCategories = ref.watch(analyticsHiddenCategoriesProvider);
    final visibleBreakdown = _getVisibleBreakdown(hiddenCategories);

    if (visibleBreakdown.isEmpty) {
      return Container(
        padding: EdgeInsets.all(tokens.gridUnit * 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_off_rounded,
                  size: 44,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                ),
                const SizedBox(height: 12),
                Text(
                  'All categories are hidden',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a category chip below or customize to show data.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = <String, double>{};
    final colors = <Color>[];
    int totalPaise = 0;

    final predefinedColors = [
      tokens.accentShopping,
      tokens.accentTransport,
      tokens.accentBills,
      tokens.accentSavings,
      tokens.accentAlert,
    ];

    for (int i = 0; i < visibleBreakdown.length; i++) {
      final cb = visibleBreakdown[i];
      data[cb.categoryName] = cb.total / 100.0;
      totalPaise += cb.total;
      colors.add(Color(cb.color != 0 ? cb.color : predefinedColors[i % predefinedColors.length].value));
    }

    final now = DateTime.now();

    return Container(
      padding: EdgeInsets.all(tokens.gridUnit * 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tap slice to view transactions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              InkWell(
                onTap: () => CategoryFilterDialog.show(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Customize',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          AspectRatio(
            aspectRatio: 1.2,
            child: ProgressDonutChart(
              data: data,
              colors: colors,
              strokeWidth: 24,
              centerRadius: 80,
              showPercentages: true,
              onSectionTapped: (categoryName, index) {
                if (index >= 0 && index < visibleBreakdown.length) {
                  final cb = visibleBreakdown[index];
                  CategoryTransactionsSheet.show(
                    context,
                    categoryId: cb.categoryId,
                    categoryName: cb.categoryName,
                    month: now.month,
                    year: now.year,
                    categoryColor: colors[index],
                  );
                }
              },
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
        ],
      ),
    );
  }

  Widget _buildLegendChips(BuildContext context, AppCustomTokens tokens) {
    if (_allCategoryBreakdown.isEmpty) return const SizedBox.shrink();

    final hiddenCategories = ref.watch(analyticsHiddenCategoriesProvider);
    final notifier = ref.read(analyticsHiddenCategoriesProvider.notifier);

    final sortedBreakdown = List<CategoryBreakdown>.from(_allCategoryBreakdown)
      ..sort((a, b) => b.total.compareTo(a.total));

    final predefinedColors = [
      tokens.accentShopping,
      tokens.accentTransport,
      tokens.accentBills,
      tokens.accentSavings,
      tokens.accentAlert,
    ];

    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Categories (tap to toggle)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: List.generate(sortedBreakdown.length, (index) {
            final cb = sortedBreakdown[index];
            final isHidden = hiddenCategories.contains(cb.categoryId);
            final color = cb.color != 0
                ? Color(cb.color)
                : predefinedColors[index % predefinedColors.length];

            return InkWell(
              onTap: () {
                notifier.toggleCategory(cb.categoryId);
              },
              onLongPress: () {
                CategoryTransactionsSheet.show(
                  context,
                  categoryId: cb.categoryId,
                  categoryName: cb.categoryName,
                  month: now.month,
                  year: now.year,
                  categoryColor: color,
                );
              },
              borderRadius: BorderRadius.circular(100),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isHidden ? 0.45 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isHidden ? Colors.grey.withOpacity(0.3) : color.withOpacity(0.3),
                      width: isHidden ? 1.0 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isHidden ? Colors.grey : color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cb.categoryName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isHidden ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        CurrencyFormatter.formatPaiseCompact(cb.total),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 14,
                        color: isHidden
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.35)
                            : color,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, AppCustomTokens tokens) {
    Color getScoreColor(int score) {
      if (score >= 80) return tokens.accentSavings;
      if (score >= 50) return tokens.accentTransport;
      if (score >= 0) return tokens.accentAlert;
      return AppColors.darkExpense;
    }

    String getStatusText(int score) {
      if (score >= 80) return 'You are on track. Keep it up!';
      if (score >= 50) return 'Caution: Budget usage is getting high.';
      if (score >= 0) return "You've exceeded your budget! Action required to balance spending.";
      return 'Critical: Budget severely exceeded! Survival mode active.';
    }

    final scoreColor = getScoreColor(_healthScore);
    final isOverBudget = _healthScore < 50;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(tokens.gridUnit * 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
            border: isOverBudget
                ? Border.all(color: scoreColor.withOpacity(0.4), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor.withOpacity(0.2), width: 6),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        '$_healthScore',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Financial Health',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isOverBudget) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.warning_amber_rounded, color: scoreColor, size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getStatusText(_healthScore),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOverBudget
                            ? scoreColor
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: isOverBudget ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        if (isOverBudget) ...[
          const SizedBox(height: AppSpacing.space3),
          Container(
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
              border: Border.all(color: scoreColor.withOpacity(0.4), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: scoreColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚨 Survival Mode Active',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You've exceeded your budget! Freeze non-essential expenses (dining out, entertainment, shopping) to prevent deepening the deficit.",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
      final color = isWarning ? tokens.accentAlert : AppColors.darkGoldPrimary;
      final icon = isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.space3),
        padding: EdgeInsets.all(tokens.gridUnit * 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
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
