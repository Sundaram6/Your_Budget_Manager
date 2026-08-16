import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_animation.dart';
import '../../theme/app_custom_tokens.dart';

class ProgressDonutChart extends StatefulWidget {
  final Map<String, double> data;
  final List<Color>? colors;
  final double centerRadius;
  final double strokeWidth;
  final bool showPercentages;
  final Widget? centerWidget;
  final void Function(String categoryKey, int index)? onSectionTapped;

  const ProgressDonutChart({
    super.key,
    required this.data,
    this.colors,
    this.centerRadius = 60,
    this.strokeWidth = 24,
    this.showPercentages = false,
    this.centerWidget,
    this.onSectionTapped,
  });

  @override
  State<ProgressDonutChart> createState() => _ProgressDonutChartState();
}

class _ProgressDonutChartState extends State<ProgressDonutChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    
    if (widget.data.isEmpty) {
      return SizedBox(
        height: (widget.centerRadius + widget.strokeWidth) * 2,
        child: Center(
          child: widget.centerWidget ?? const SizedBox.shrink(),
        ),
      );
    }

    final double total = widget.data.values.fold(0, (sum, item) => sum + item);
    final List<Color> fallbackColors = [
      tokens.accentGroceries,
      tokens.accentShopping,
      tokens.accentBills,
      tokens.accentTransport,
      tokens.accentSavings,
    ];
    final List<Color> palette = widget.colors ?? fallbackColors;

    int colorIndex = 0;
    final entries = widget.data.entries.toList();
    final List<PieChartSectionData> sections = entries.map((entry) {
      final idx = colorIndex;
      final color = palette[colorIndex % palette.length];
      colorIndex++;
      
      final isTouched = _touchedIndex == idx;
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: widget.showPercentages || isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: isTouched ? widget.strokeWidth + 6 : widget.strokeWidth,
        titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        showTitle: widget.showPercentages || isTouched,
      );
    }).toList();

    return SizedBox(
      height: (widget.centerRadius + widget.strokeWidth + 6) * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.centerWidget != null) widget.centerWidget!,
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: widget.centerRadius,
              sections: sections,
              pieTouchData: PieTouchData(
                enabled: widget.onSectionTapped != null,
                touchCallback: (event, response) {
                  if (widget.onSectionTapped == null) return;
                  
                  final touchedIdx = response?.touchedSection?.touchedSectionIndex;
                  if (event is FlTapUpEvent && touchedIdx != null && touchedIdx >= 0 && touchedIdx < entries.length) {
                    final key = entries[touchedIdx].key;
                    widget.onSectionTapped!(key, touchedIdx);
                  }
                  
                  if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                    setState(() => _touchedIndex = null);
                    return;
                  }
                  
                  setState(() {
                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
            duration: AppAnimation.durationNormal,
            curve: AppAnimation.curveSwiftOut,
          ),
        ],
      ),
    );
  }
}
