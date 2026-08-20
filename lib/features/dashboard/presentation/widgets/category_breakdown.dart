import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../engines/analytics/models/analytics_models.dart';
import '../../../analytics/presentation/widgets/category_transactions_sheet.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<CategoryBreakdown> breakdowns;
  final void Function(CategoryBreakdown category)? onCategoryTap;
  final int? month;
  final int? year;

  const CategoryBreakdownWidget({
    super.key,
    required this.breakdowns,
    this.onCategoryTap,
    this.month,
    this.year,
  });

  void _handleCategoryTap(BuildContext context, CategoryBreakdown b) {
    if (onCategoryTap != null) {
      onCategoryTap!(b);
    } else {
      final now = DateTime.now();
      CategoryTransactionsSheet.show(
        context,
        categoryId: b.categoryId,
        categoryName: b.categoryName,
        month: month ?? now.month,
        year: year ?? now.year,
        categoryColor: Color(b.color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    if (breakdowns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space6),
          child: Column(
            children: [
              Icon(
                PhosphorIcons.chartPie,
                size: 36,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                'No expense data yet.',
                style: AppTypography.bodyRegular.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Top category by percentage for the centered donut label
    final top = breakdowns.reduce(
        (a, b) => a.percentage > b.percentage ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: tokens.surfaceGlass,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        border: Border.all(color: tokens.borderGlass),
      ),
      child: Column(
        children: [
          // Donut chart with centered overlay
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60, // Bolder ring — was 50
                    sections: breakdowns.map((b) {
                      return PieChartSectionData(
                        value: b.percentage,
                        title: '',       // Labels moved to legend below
                        color: Color(b.color),
                        radius: 52,      // Thicker ring — was 40
                      );
                    }).toList(),
                    // Phase 28 touch callback — untouched
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent &&
                            response?.touchedSection != null) {
                          final idx =
                              response!.touchedSection!.touchedSectionIndex;
                          if (idx >= 0 && idx < breakdowns.length) {
                            _handleCategoryTap(context, breakdowns[idx]);
                          }
                        }
                      },
                    ),
                  ),
                ),
                // Centered top-category percentage + name overlay
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${top.percentage.toStringAsFixed(0)}%',
                      style: AppTypography.statValue.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      top.categoryName,
                      style: AppTypography.bodyRegular.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.55),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // Legend rows — Cabinet Grotesk/Satoshi, 14dp vertical padding
          ...breakdowns.map((b) {
            return InkWell(
              onTap: () => _handleCategoryTap(context, b),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 7, horizontal: 4),
                child: Row(
                  children: [
                    // Rounded-square swatch
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(b.color),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        b.categoryName,
                        style: AppTypography.bodyRegular.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      b.total.toCurrency(),
                      style: AppTypography.buttonLabel.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
