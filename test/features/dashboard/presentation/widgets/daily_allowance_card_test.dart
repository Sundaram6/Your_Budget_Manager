import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/engines/budget/models/daily_allowance.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/daily_allowance_card.dart';

void main() {
  testWidgets('DailyAllowanceCard renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: DailyAllowanceCard(
            allowance: DailyAllowance(
              amount: 50.0,
              remaining: 500.0,
              daysLeft: 10,
              isHealthy: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DailyAllowanceCard), findsOneWidget);
    expect(find.textContaining('comfortably spend'), findsOneWidget);
  });
}
