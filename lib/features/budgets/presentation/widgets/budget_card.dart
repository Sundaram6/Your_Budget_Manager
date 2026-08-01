import 'package:flutter/material.dart';

import '../../../budgets/domain/entities/budget.dart';
import '../screens/budget_detail_screen.dart';
import 'budget_progress_ring.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Budget: \${budget.categoryId}'),
        subtitle: const Text('Limit: \${budget.limit.value}'),
        trailing: const BudgetProgressRing(progress: 0.5),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetDetailScreen(budgetId: budget.id)));
        },
      ),
    );
  }
}
