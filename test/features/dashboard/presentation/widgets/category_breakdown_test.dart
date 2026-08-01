import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/engines/analytics/models/analytics_models.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/category_breakdown.dart';

void main() {
  testWidgets('CategoryBreakdownWidget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: CategoryBreakdownWidget(
              breakdowns: [
                CategoryBreakdown(
                  categoryId: '1',
                  categoryName: 'Food',
                  color: 0xFFFF0000,
                  icon: 'food',
                  total: 100.0,
                  percentage: 100.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.byType(CategoryBreakdownWidget), findsOneWidget);
  });
}
