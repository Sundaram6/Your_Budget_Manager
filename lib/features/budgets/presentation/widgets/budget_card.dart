import 'package:flutter/material.dart';

import '../../../../database/app_database.dart';
import '../screens/budget_detail_screen.dart';
import 'budget_progress_ring.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final amountRupees = budget.amount / 100;

    return Card(
      child: ListTile(
        title: Text(budget.categoryId != null ? 'Category Budget' : 'Overall Monthly Budget'),
        subtitle: Text('Limit: ₹${amountRupees.toStringAsFixed(0)}'),
        trailing: const BudgetProgressRing(progress: 0.5),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetDetailScreen(budgetId: budget.id)));
        },
      ),
    );
  }
}
