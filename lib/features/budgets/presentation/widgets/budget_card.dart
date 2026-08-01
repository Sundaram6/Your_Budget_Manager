import 'package:flutter/material.dart';
import '../../../budgets/domain/entities/budget.dart';
import 'budget_progress_ring.dart';
import '../screens/budget_detail_screen.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Budget: \${budget.categoryId}'),
        subtitle: Text('Limit: \${budget.limit.value}'),
        trailing: BudgetProgressRing(progress: 0.5),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetDetailScreen(budget: budget)));
        },
      ),
    );
  }
}
