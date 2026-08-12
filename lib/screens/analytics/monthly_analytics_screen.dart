import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../engines/analytics/analytics_engine.dart';
import '../../engines/analytics/analytics_engine_provider.dart';
import '../../engines/analytics/models/analytics_models.dart';

class MonthlyAnalyticsScreen extends ConsumerStatefulWidget {
  final DateTime initialMonth;

  const MonthlyAnalyticsScreen({super.key, required this.initialMonth});

  @override
  ConsumerState<MonthlyAnalyticsScreen> createState() =>
      _MonthlyAnalyticsScreenState();
}

class _MonthlyAnalyticsScreenState
    extends ConsumerState<MonthlyAnalyticsScreen> {
  late DateTime _selectedMonth;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  void _prevMonth() =>
      setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
  void _nextMonth() =>
      setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));

  static const List<Color> _chartColors = [
    Color(0xFFD4AF37),
    Color(0xFF4FC3F7),
    Color(0xFF81C784),
    Color(0xFFFF8A65),
    Color(0xFFBA68C8),
    Color(0xFFE57373),
    Color(0xFF4DB6AC),
    Color(0xFFFFF176),
  ];

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(analyticsEngineProvider);
    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${DateFormat('MMMM yyyy').format(_selectedMonth)} Analytics',
          style: const TextStyle(
            color: AppColors.darkGoldPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<_AnalyticsData>(
        future: _loadData(engine),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkGoldPrimary),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          }
          final data = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Selector
                _buildMonthSelector(),
                const SizedBox(height: 20),

                // Donut Chart
                if (data.breakdown.isNotEmpty)
                  _buildDonutCard(data)
                else
                  _buildNoDataCard('No expense data for this month'),

                const SizedBox(height: 20),

                // Stats Grid
                _buildStatsGrid(data),

                const SizedBox(height: 20),

                // Zero Expense Streak
                _buildStreakCard(data.streak),

                const SizedBox(height: 20),

                // Daily Heat Map
                _buildHeatMap(data.dailyTrends),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_AnalyticsData> _loadData(AnalyticsEngine engine) async {
    final y = _selectedMonth.year;
    final m = _selectedMonth.month;
    final results = await Future.wait([
      engine.getCategoryBreakdown(y, m),
      engine.getDailyTrend(y, m),
      engine.getMonthlyTotal(y, m),
      engine.getMonthlyIncome(y, m),
      engine.getZeroExpenseDays(y, m),
      engine.getCurrentZeroExpenseStreak(year: y, month: m),
      engine.getTopSpendingDay(y, m),
      engine.getMostSpentCategory(y, m),
    ]);
    return _AnalyticsData(
      breakdown: results[0] as List<CategoryBreakdown>,
      dailyTrends: results[1] as List<DailyTrend>,
      totalExpense: results[2] as int,
      totalIncome: results[3] as int,
      zeroExpenseDays: results[4] as int,
      streak: results[5] as int,
      topSpendingDay: results[6] as (DateTime, int)?,
      mostSpentCategory: results[7] as (String, int)?,
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.darkTextSecondary),
          onPressed: _prevMonth,
        ),
        Text(
          DateFormat('MMMM yyyy').format(_selectedMonth),
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.darkTextSecondary),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildDonutCard(_AnalyticsData data) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Category Breakdown'),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: data.breakdown.asMap().entries.map((e) {
                      final isTouched = _touchedIndex == e.key;
                      return PieChartSectionData(
                        color: _chartColors[e.key % _chartColors.length],
                        value: e.value.total.toDouble(),
                        title: isTouched ? '${e.value.percentage.toStringAsFixed(1)}%' : '',
                        radius: isTouched ? 70 : 58,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    }).toList(),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex =
                              response?.touchedSection?.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Spent',
                        style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 11)),
                    Text(
                      CurrencyFormatter.formatPaiseNoDecimals(data.totalExpense),
                      style: const TextStyle(
                        color: AppColors.darkGoldPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.breakdown.asMap().entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _chartColors[e.key % _chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${e.value.categoryName} (${e.value.percentage.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(_AnalyticsData data) {
    final dayFmt = DateFormat('d MMM');
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard(
          icon: Icons.arrow_downward,
          iconColor: Colors.greenAccent,
          label: 'Total Credited',
          value: CurrencyFormatter.formatPaiseNoDecimals(data.totalIncome),
        ),
        _statCard(
          icon: Icons.category,
          iconColor: AppColors.darkGoldPrimary,
          label: 'Most Spent On',
          value: data.mostSpentCategory != null
              ? '${data.mostSpentCategory!.$1}\n${CurrencyFormatter.formatPaiseNoDecimals(data.mostSpentCategory!.$2)}'
              : 'N/A',
        ),
        _statCard(
          icon: Icons.today,
          iconColor: Colors.orangeAccent,
          label: 'Top Spending Day',
          value: data.topSpendingDay != null
              ? '${dayFmt.format(data.topSpendingDay!.$1)}\n${CurrencyFormatter.formatPaiseNoDecimals(data.topSpendingDay!.$2)}'
              : 'N/A',
        ),
        _statCard(
          icon: Icons.check_circle_outline,
          iconColor: Colors.lightGreenAccent,
          label: 'Zero Spend Days',
          value: '${data.zeroExpenseDays} days',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkTextTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    String badge = '';
    Color borderColor = const Color(0xFF2A2A2A);
    final subtitle = streak == 0
        ? 'Spend nothing today to start a streak!'
        : 'You had no expenses for $streak consecutive days. Keep it up!';

    if (streak >= 30) {
      badge = '🏆 Monthly Master!';
      borderColor = AppColors.darkGoldPrimary;
    } else if (streak >= 7) {
      badge = '⭐ Weekly Saver!';
      borderColor = Colors.lightGreenAccent;
    } else if (streak >= 3) {
      badge = '🔥 On a roll!';
      borderColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: streak >= 3 ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: streak > 0 ? AppColors.darkGoldPrimary : AppColors.darkTextTertiary,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  streak > 0 ? '$streak-Day Zero Spend Streak' : 'Zero Spend Streak',
                  style: TextStyle(
                    color: streak > 0 ? AppColors.darkGoldPrimary : AppColors.darkTextSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13)),
          if (badge.isNotEmpty) ...[
            const SizedBox(height: 10),
            _AnimatedBadge(badge: badge),
          ],
        ],
      ),
    );
  }

  Widget _buildHeatMap(List<DailyTrend> trends) {
    if (trends.isEmpty) return const SizedBox.shrink();

    final maxSpend = trends.map((t) => t.total).fold<int>(0, (a, b) => a > b ? a : b);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Daily Spending Heat Map'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: trends.map((trend) {
              final intensity = maxSpend > 0 ? trend.total / maxSpend : 0.0;
              final color = _heatColor(intensity);
              return GestureDetector(
                onTap: () => _showDayTooltip(trend),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      '${trend.date.day}',
                      style: TextStyle(
                        color: intensity > 0.5 ? Colors.black : AppColors.darkTextTertiary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _heatLegendBox(_heatColor(0), '₹0'),
              const SizedBox(width: 8),
              _heatLegendBox(_heatColor(0.3), 'Low'),
              const SizedBox(width: 8),
              _heatLegendBox(_heatColor(0.6), 'Mid'),
              const SizedBox(width: 8),
              _heatLegendBox(_heatColor(1.0), 'High'),
            ],
          ),
        ],
      ),
    );
  }

  Color _heatColor(double intensity) {
    if (intensity <= 0) return const Color(0xFF2A2A2A);
    if (intensity < 0.33) return AppColors.darkGoldPrimary.withValues(alpha: 0.3 + intensity);
    if (intensity < 0.66) return Colors.orange.withValues(alpha: 0.5 + intensity * 0.3);
    return Colors.red.withValues(alpha: 0.5 + intensity * 0.5);
  }

  Widget _heatLegendBox(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 14,
            height: 14,
            decoration:
                BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.darkTextTertiary, fontSize: 10)),
      ],
    );
  }

  void _showDayTooltip(DailyTrend trend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(trend.date),
                style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                trend.total > 0 ? 'Spent: ${CurrencyFormatter.formatPaiseNoDecimals(trend.total)}' : 'No expenses',
                style: TextStyle(
                  color: trend.total > 0 ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart, color: AppColors.darkTextTertiary, size: 48),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(color: AppColors.darkTextSecondary)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.darkTextTertiary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ------- Data holder -------
class _AnalyticsData {
  final List<CategoryBreakdown> breakdown;
  final List<DailyTrend> dailyTrends;
  final int totalExpense;
  final int totalIncome;
  final int zeroExpenseDays;
  final int streak;
  final (DateTime, int)? topSpendingDay;
  final (String, int)? mostSpentCategory;

  const _AnalyticsData({
    required this.breakdown,
    required this.dailyTrends,
    required this.totalExpense,
    required this.totalIncome,
    required this.zeroExpenseDays,
    required this.streak,
    required this.topSpendingDay,
    required this.mostSpentCategory,
  });
}

// ------- Animated badge for streak -------
class _AnimatedBadge extends StatefulWidget {
  final String badge;
  const _AnimatedBadge({required this.badge});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.darkGoldPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.4)),
        ),
        child: Text(
          widget.badge,
          style: const TextStyle(
            color: AppColors.darkGoldPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
