import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class SavingsProgressRing extends StatelessWidget {
  const SavingsProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 64.0,
    this.strokeWidth = 6.0,
    this.child,
  });

  final double progress; // 0.0 to 1.0
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            color: context.colorScheme.surfaceContainerHighest,
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            color: color,
            strokeCap: StrokeCap.round,
          ),
          if (child != null) Center(child: child!),
        ],
      ),
    );
  }
}
