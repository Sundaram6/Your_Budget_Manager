import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/engines/budget/models/budget_progress.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/budget_summary.dart';

void main() {
  testWidgets('BudgetSummaryWidget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: BudgetSummaryWidget(
            budgets: [
              BudgetProgress(
                spent: 100.0,
                limit: 500.0,
                percentage: 20.0,
                isOverBudget: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(BudgetSummaryWidget), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
  });
}
