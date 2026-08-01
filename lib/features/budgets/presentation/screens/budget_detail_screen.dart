import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../budgets/domain/entities/budget.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final Budget budget;
  const BudgetDetailScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Limit: \${budget.limit.value}'),
            // Trend chart placeholder
            const Expanded(child: Center(child: Text('Trend Chart Placeholder'))),
          ],
        ),
      ),
    );
  }
}
