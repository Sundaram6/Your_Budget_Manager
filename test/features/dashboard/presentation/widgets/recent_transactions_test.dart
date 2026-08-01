import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/recent_transactions.dart';

void main() {
  testWidgets('RecentTransactionsWidget renders empty state correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: RecentTransactionsWidget(
            transactions: [],
          ),
        ),
      ),
    );

    expect(find.byType(RecentTransactionsWidget), findsOneWidget);
    expect(find.text('No recent transactions.'), findsOneWidget);
  });
}
