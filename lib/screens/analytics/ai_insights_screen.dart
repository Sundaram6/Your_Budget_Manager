import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../engines/intelligence/intelligence_engine_provider.dart';
import '../../engines/intelligence/models/ai_insight.dart';

class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _prevMonth() =>
      setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return; // Don't go into future
    setState(() => _selectedMonth = next);
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(intelligenceEngineProvider);

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Financial Insights',
          style: TextStyle(
            color: AppColors.darkGoldPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
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
                  icon: Icon(
                    Icons.chevron_right,
                    color: _isCurrentMonth() ? AppColors.darkTextTertiary : AppColors.darkTextSecondary,
                  ),
                  onPressed: _isCurrentMonth() ? null : _nextMonth,
                ),
              ],
            ),
          ),

          // Insights list
          Expanded(
            child: FutureBuilder<List<AiInsight>>(
              future: engine.generateInsightsForMonth(
                _selectedMonth.year,
                _selectedMonth.month,
              ),
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
                final insights = snap.data ?? [];
                if (insights.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.insights, color: AppColors.darkTextTertiary, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found for\n${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: insights.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final insight = insights[index];
                    return _InsightCard(insight: insight);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentMonth() {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }
}

class _InsightCard extends StatelessWidget {
  final AiInsight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig(insight.type);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: config.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(config.icon, color: config.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _InsightConfig _typeConfig(InsightType type) {
    switch (type) {
      case InsightType.warning:
        return _InsightConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
          iconBg: Colors.orange.withValues(alpha: 0.12),
          borderColor: Colors.orange.withValues(alpha: 0.3),
        );
      case InsightType.achievement:
        return _InsightConfig(
          icon: Icons.emoji_events,
          iconColor: AppColors.darkGoldPrimary,
          iconBg: AppColors.darkGoldPrimary.withValues(alpha: 0.12),
          borderColor: AppColors.darkGoldPrimary.withValues(alpha: 0.3),
        );
      case InsightType.tip:
        return _InsightConfig(
          icon: Icons.lightbulb_outline,
          iconColor: Colors.lightBlueAccent,
          iconBg: Colors.lightBlueAccent.withValues(alpha: 0.12),
          borderColor: Colors.lightBlueAccent.withValues(alpha: 0.3),
        );
      case InsightType.suggestion:
        return _InsightConfig(
          icon: Icons.recommend,
          iconColor: Colors.purpleAccent,
          iconBg: Colors.purpleAccent.withValues(alpha: 0.12),
          borderColor: Colors.purpleAccent.withValues(alpha: 0.3),
        );
    }
  }
}

class _InsightConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
  const _InsightConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
  });
}
