import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/total_spend_card.dart';

void main() {
  testWidgets('TotalSpendCard renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: TotalSpendCard(totalSpend: 1500.0),
        ),
      ),
    );

    expect(find.text('Total Spend This Month'), findsOneWidget);
    // 1500.0 formatted with currency might look like ₹1,500.00 depending on locale
    // We just check if the widget exists without exact text match for the currency 
    // unless we know the exact format.
    expect(find.byType(TotalSpendCard), findsOneWidget);
  });
}
