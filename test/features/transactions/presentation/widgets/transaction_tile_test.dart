import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/transaction_tile.dart';

void main() {
  final List<Category> testCategories = [
    const Category(
      id: 'cat_groceries',
      name: 'Groceries',
      icon: 'shopping_cart',
      color: 0xFF2196F3,
      isDefault: true,
    ),
    const Category(
      id: 'cat_salary',
      name: 'Salary',
      icon: 'attach_money',
      color: 0xFF4CAF50,
      isDefault: true,
    ),
  ];

  testWidgets('TransactionTile renders expense amount with - prefix in rupees from paise', (WidgetTester tester) async {
    final tx = Transaction(
      id: 'tx-tile-1',
      amount: const Amount(17100), // 17100 paise = ₹171.00
      date: DateTime(2026, 8, 12),
      categoryId: 'cat_groceries',
      type: TransactionType.expense,
      note: 'Dmart store',
      paymentMethod: PaymentMethod.debit_card,
      cardLast4: '9988',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TransactionTile(transaction: tx),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify correct rupee formatting
    expect(find.text('-₹171.00'), findsOneWidget);
    expect(find.text('-₹17,100.00'), findsNothing);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Debit Card •9988 • Dmart store'), findsOneWidget);
  });

  testWidgets('TransactionTile renders income amount with + prefix in rupees from paise', (WidgetTester tester) async {
    final tx = Transaction(
      id: 'tx-tile-2',
      amount: const Amount(8500000), // 8500000 paise = ₹85,000.00
      date: DateTime(2026, 8, 12),
      categoryId: 'cat_salary',
      type: TransactionType.income,
      note: 'August Salary',
      paymentMethod: PaymentMethod.upi,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: TransactionTile(transaction: tx),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify correct rupee formatting
    expect(find.text('+₹85,000.00'), findsOneWidget);
    expect(find.text('+₹8,500,000.00'), findsNothing);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('UPI • August Salary'), findsOneWidget);
  });
}
