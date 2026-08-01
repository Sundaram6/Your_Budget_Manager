import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_animation.dart';

class BudgetProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? color;

  const BudgetProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0.0, 1.0);
    final bool isOverBudget = progress > 1.0;
    
    final Color barColor = color ?? (isOverBudget ? AppColors.darkExpense : AppColors.darkGoldPrimary);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.darkSurface3,
            borderRadius: AppRadius.full,
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: AppAnimation.durationNormal,
                curve: AppAnimation.curveSwiftOut,
                width: constraints.maxWidth * clampedProgress,
                height: height,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: AppRadius.full,
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
