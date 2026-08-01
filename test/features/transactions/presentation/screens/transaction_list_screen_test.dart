import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/features/transactions/presentation/controllers/transaction_list_controller.dart';
import 'package:your_budget_manager/features/transactions/presentation/screens/transaction_list_screen.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';

class MockTransactionListController extends TransactionListController {
  @override
  FutureOr<TransactionListState> build() {
    return TransactionListState(
      selectedMonth: DateTime.now(),
      groupedTransactions: {},
    );
  }
}

void main() {
  testWidgets('TransactionListScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListControllerProvider.overrideWith(() => MockTransactionListController()),
          categoriesStreamProvider.overrideWith((ref) => Stream.value([])),
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
}
