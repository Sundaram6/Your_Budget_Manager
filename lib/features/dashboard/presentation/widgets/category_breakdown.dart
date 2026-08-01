import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../engines/analytics/models/analytics_models.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<CategoryBreakdown> breakdowns;

  const CategoryBreakdownWidget({super.key, required this.breakdowns});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    if (breakdowns.isEmpty) {
      return const Center(child: Text('No expense data yet.'));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: tokens.surfaceGlass,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        border: Border.all(color: tokens.borderGlass),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: breakdowns.map((b) {
                  return PieChartSectionData(
                    value: b.percentage,
                    title: '${b.percentage.toStringAsFixed(1)}%',
                    color: Color(b.color),
                    radius: 40,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          ...breakdowns.map((b) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(b.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Expanded(
                    child: Text(
                      b.categoryName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    b.total.toCurrency(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
