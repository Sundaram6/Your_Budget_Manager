import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/transactions/presentation/controllers/transaction_list_controller.dart';
import 'package:your_budget_manager/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';

class MockEmptyTransactionListController extends TransactionListController {
  @override
  FutureOr<TransactionListState> build() {
    return TransactionListState(
      selectedMonth: DateTime(2026, 8, 1),
      groupedTransactions: {},
    );
  }
}

class MockPopulatedTransactionListController extends TransactionListController {
  @override
  FutureOr<TransactionListState> build() {
    final date = DateTime(2026, 8, 12);
    return TransactionListState(
      selectedMonth: DateTime(2026, 8, 1),
      groupedTransactions: {
        date: [
          Transaction(
            id: 'tx-1',
            amount: const Amount(17100), // 17100 paise = ₹171.00
            date: date,
            categoryId: 'cat_food',
            type: TransactionType.expense,
            note: 'Lunch at Cafe',
            paymentMethod: PaymentMethod.debit_card,
            cardLast4: '4521',
          ),
          Transaction(
            id: 'tx-2',
            amount: const Amount(500000), // 500000 paise = ₹5,000.00
            date: date,
            categoryId: 'cat_income',
            type: TransactionType.income,
            note: 'Freelance payment',
            paymentMethod: PaymentMethod.upi,
          ),
        ],
      },
    );
  }
}

void main() {
  final List<Category> testCategories = [
    const Category(
      id: 'cat_food',
      name: 'Food & Dining',
      icon: 'restaurant',
      color: 0xFFFF5722,
      isDefault: true,
    ),
    const Category(
      id: 'cat_income',
      name: 'Income',
      icon: 'work',
      color: 0xFF4CAF50,
      isDefault: true,
    ),
  ];

  testWidgets('TransactionListScreen renders empty state properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListControllerProvider.overrideWith(() => MockEmptyTransactionListController()),
          categoriesStreamProvider.overrideWith((ref) => Stream.value(<Category>[])),
        ],
        child: const MaterialApp(
          home: TransactionListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.text('No transactions for this month.'), findsOneWidget);
  });

  testWidgets('TransactionListScreen renders accurate rupee amount formatted from integer paise (no 100x bug)', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListControllerProvider.overrideWith(() => MockPopulatedTransactionListController()),
          categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const TransactionListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 17100 paise MUST be formatted as -₹171.00, NOT -₹17,100.00
    expect(find.text('-₹171.00'), findsOneWidget);
    expect(find.text('-₹17,100.00'), findsNothing);

    // 500000 paise MUST be formatted as +₹5,000.00, NOT +₹500,000.00
    expect(find.text('+₹5,000.00'), findsOneWidget);
    expect(find.text('+₹500,000.00'), findsNothing);

    // Verify category and note subtitles render
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Debit Card •4521 • Lunch at Cafe'), findsOneWidget);
    expect(find.text('UPI • Freelance payment'), findsOneWidget);
  });
}
