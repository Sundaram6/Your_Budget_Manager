import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/transaction_detail_sheet.dart';

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

  testWidgets('TransactionDetailSheet renders accurate rupee amount from paise and payment method', (WidgetTester tester) async {
    final tx = Transaction(
      id: 'tx-sheet-1',
      amount: const Amount(17100), // 17100 paise = ₹171.00
      date: DateTime(2026, 8, 12, 14, 30),
      categoryId: 'cat_food',
      type: TransactionType.expense,
      note: 'Lunch at Cafe',
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
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TransactionDetailSheet(transaction: tx),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify correct rupee formatting
    expect(find.text('₹171.00'), findsOneWidget);
    expect(find.text('₹17,100.00'), findsNothing);

    // Verify detail labels
    expect(find.text('Transaction Details'), findsOneWidget);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Debit Card •4521'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Lunch at Cafe'), findsOneWidget);
  });
}
