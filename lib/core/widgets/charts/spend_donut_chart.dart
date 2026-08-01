import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_animation.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class SpendDonutChart extends StatelessWidget {
  final Map<String, double> data;
  final List<Color>? colors;

  const SpendDonutChart({
    super.key,
    required this.data,
    this.colors,
  });

  List<Color> get _defaultColors => [
        AppColors.darkGoldPrimary,
        AppColors.darkIncome,
        AppColors.darkExpense,
        const Color(0xFF3B82F6), // Blue
        const Color(0xFF8B5CF6), // Purple
        const Color(0xFFF97316), // Orange
      ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No data', style: TextStyle(color: AppColors.darkTextTertiary)),
        ),
      );
    }

    final double total = data.values.fold(0, (sum, item) => sum + item);
    final List<Color> palette = colors ?? _defaultColors;

    int colorIndex = 0;
    final List<PieChartSectionData> sections = data.entries.map((entry) {
      final color = palette[colorIndex % palette.length];
      colorIndex++;
      
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: AppTypography.microTag.copyWith(color: AppColors.darkTextPrimary),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: sections,
          pieTouchData: PieTouchData(enabled: true),
        ),
        duration: AppAnimation.durationNormal,
        curve: AppAnimation.curveSwiftOut,
      ),
    );
  }
}
