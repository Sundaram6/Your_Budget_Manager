import 'package:flutter/material.dart';

class BudgetProgressRing extends StatelessWidget {
  final double progress;
  const BudgetProgressRing({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(value: progress);
  }
}
