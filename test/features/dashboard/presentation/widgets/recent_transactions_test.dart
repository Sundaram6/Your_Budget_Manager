import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';

void main() {
  final List<Category> testCategories = [
    const Category(
      id: 'cat_food',
      name: 'Food & Dining',
      icon: 'restaurant',
      color: 0xFFFF5722,
      isDefault: true,
    ),
  ];

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

  testWidgets('RecentTransactionsWidget renders accurate rupee amount from paise', (WidgetTester tester) async {
    final tx = Transaction(
      id: 'tx-recent-1',
      amount: const Amount(17100), // 17100 paise = ₹171.00
      date: DateTime(2026, 8, 12),
      categoryId: 'cat_food',
      type: TransactionType.expense,
      note: 'Dinner',
      paymentMethod: PaymentMethod.debit_card,
      cardLast4: '4521',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: RecentTransactionsWidget(
              transactions: [tx],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify correct rupee formatting
    expect(find.text('₹171.00'), findsOneWidget);
    expect(find.text('₹17,100.00'), findsNothing);
    expect(find.text('Food & Dining'), findsOneWidget);
  });
}
