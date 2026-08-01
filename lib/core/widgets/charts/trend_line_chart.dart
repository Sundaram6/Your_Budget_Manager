import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_animation.dart';

class TrendLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color? lineColor;
  final double maxY;
  final double minY;

  const TrendLineChart({
    super.key,
    required this.spots,
    this.lineColor,
    this.maxY = 100,
    this.minY = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = lineColor ?? AppColors.darkGoldPrimary;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4 == 0 ? 1 : (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.darkBorderMedium,
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: AppTypography.microTag.copyWith(color: AppColors.darkTextTertiary),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: AppTypography.microTag.copyWith(color: AppColors.darkTextTertiary),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: spots.isEmpty ? 0 : spots.first.x,
          maxX: spots.isEmpty ? 0 : spots.last.x,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        swapAnimationDuration: AppAnimation.durationNormal,
        swapAnimationCurve: AppAnimation.curveSwiftOut,
      ),
    );
  }
}
