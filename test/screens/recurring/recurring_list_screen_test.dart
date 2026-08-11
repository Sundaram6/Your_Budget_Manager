import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';
import 'package:your_budget_manager/screens/recurring/recurring_list_screen.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: child,
    );
  }

  testWidgets('RecurringListScreen renders empty state when database is empty', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        RecurringListScreen(
          stream: Stream.value([]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recurring Transactions'), findsOneWidget);
    expect(find.text('No recurring transactions yet'), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('RecurringListScreen renders transaction card when data is present', (tester) async {
    final now = DateTime.now();
    final item = RecurringTransactionModel(
      id: 'rec_screen_1',
      title: 'Netflix HD',
      amountPaise: 64900,
      categoryId: 'cat_entertainment',
      type: 'expense',
      frequency: 'monthly',
      intervalDays: null,
      startDate: now,
      endDate: null,
      nextDueDate: DateTime(2026, 9, 1),
      lastGeneratedDate: null,
      isActive: true,
      autoConfirm: false,
      notes: null,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      buildTestableWidget(
        RecurringListScreen(
          stream: Stream.value([item]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MONTHLY'), findsOneWidget);
    expect(find.text('Netflix HD'), findsOneWidget);
    expect(find.textContaining('₹649'), findsOneWidget);
  });

  testWidgets('RecurringListScreen renders PAUSED badge when inactive', (tester) async {
    final now = DateTime.now();
    final item = RecurringTransactionModel(
      id: 'rec_screen_2',
      title: 'Gym Paused',
      amountPaise: 150000,
      categoryId: 'cat_health',
      type: 'expense',
      frequency: 'monthly',
      intervalDays: null,
      startDate: now,
      endDate: null,
      nextDueDate: DateTime(2026, 9, 1),
      lastGeneratedDate: null,
      isActive: false,
      autoConfirm: false,
      notes: null,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      buildTestableWidget(
        RecurringListScreen(
          stream: Stream.value([item]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('Gym Paused'), findsOneWidget);
  });
}
