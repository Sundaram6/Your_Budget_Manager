import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_animation.dart';
import '../../theme/app_custom_tokens.dart';

class ProgressDonutChart extends StatelessWidget {
  final Map<String, double> data;
  final List<Color>? colors;
  final double centerRadius;
  final double strokeWidth;
  final bool showPercentages;
  final Widget? centerWidget;

  const ProgressDonutChart({
    super.key,
    required this.data,
    this.colors,
    this.centerRadius = 60,
    this.strokeWidth = 24,
    this.showPercentages = false,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    
    if (data.isEmpty) {
      return SizedBox(
        height: (centerRadius + strokeWidth) * 2,
        child: Center(
          child: centerWidget ?? const SizedBox.shrink(),
        ),
      );
    }

    final double total = data.values.fold(0, (sum, item) => sum + item);
    final List<Color> fallbackColors = [
      tokens.accentGroceries,
      tokens.accentShopping,
      tokens.accentBills,
      tokens.accentTransport,
      tokens.accentSavings,
    ];
    final List<Color> palette = colors ?? fallbackColors;

    int colorIndex = 0;
    final List<PieChartSectionData> sections = data.entries.map((entry) {
      final color = palette[colorIndex % palette.length];
      colorIndex++;
      
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: showPercentages ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: strokeWidth,
        titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        showTitle: showPercentages,
      );
    }).toList();

    return SizedBox(
      height: (centerRadius + strokeWidth) * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (centerWidget != null) centerWidget!,
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: centerRadius,
              sections: sections,
              pieTouchData: PieTouchData(enabled: false), // Disable touch for progress donuts
            ),
            duration: AppAnimation.durationNormal,
            curve: AppAnimation.curveSwiftOut,
          ),
        ],
      ),
    );
  }
}
