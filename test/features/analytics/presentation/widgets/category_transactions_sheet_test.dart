import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/providers/database_providers.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/analytics/presentation/widgets/category_transactions_sheet.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/categories/domain/repositories/category_repository.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/transaction_detail_sheet.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockTransactionRepository mockTxRepo;
  late MockCategoryRepository mockCatRepo;

  setUp(() {
    mockTxRepo = MockTransactionRepository();
    mockCatRepo = MockCategoryRepository();
  });

  group('Phase 28: CategoryTransactionsSheet Widget Tests', () {
    final foodTxs = [
      Transaction(
        id: 'tx_1',
        amount: const Amount(120000), // ₹1,200
        date: DateTime(2026, 8, 10),
        categoryId: 'cat_food',
        type: TransactionType.expense,
        note: 'Supermarket grocery',
      ),
      Transaction(
        id: 'tx_2',
        amount: const Amount(80000), // ₹800
        date: DateTime(2026, 8, 14),
        categoryId: 'cat_food',
        type: TransactionType.expense,
        note: 'Dinner with friends',
      ),
    ];

    const foodCategory = Category(
      id: 'cat_food',
      name: 'Food & Dining',
      color: 0xFF4CAF50,
      icon: 'restaurant',
    );

    testWidgets('Renders category header, total amount, transaction list in Dark Theme', (tester) async {
      when(() => mockTxRepo.watchTransactionsByDateRange(any(), any()))
          .thenAnswer((_) => Stream.value(foodTxs));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionRepositoryProvider.overrideWithValue(mockTxRepo),
            categoryRepositoryProvider.overrideWithValue(mockCatRepo),
            categoriesStreamProvider.overrideWith((ref) => Stream.value([foodCategory])),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CategoryTransactionsSheet.show(
                    context,
                    categoryId: 'cat_food',
                    categoryName: 'Food & Dining',
                    month: 8,
                    year: 2026,
                    categoryColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Assert header
      expect(find.text('Food & Dining'), findsWidgets);
      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('2 transactions'), findsOneWidget);
      expect(find.text('₹2,000'), findsOneWidget);

      // Assert transactions
      expect(find.text('Supermarket grocery'), findsOneWidget);
      expect(find.text('Dinner with friends'), findsOneWidget);
    });

    testWidgets('Tapping transaction in sheet opens TransactionDetailSheet in Light Theme', (tester) async {
      when(() => mockTxRepo.watchTransactionsByDateRange(any(), any()))
          .thenAnswer((_) => Stream.value(foodTxs));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionRepositoryProvider.overrideWithValue(mockTxRepo),
            categoryRepositoryProvider.overrideWithValue(mockCatRepo),
            categoriesStreamProvider.overrideWith((ref) => Stream.value([foodCategory])),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CategoryTransactionsSheet.show(
                    context,
                    categoryId: 'cat_food',
                    categoryName: 'Food & Dining',
                    month: 8,
                    year: 2026,
                  ),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap on the first transaction
      await tester.tap(find.text('Supermarket grocery'));
      await tester.pumpAndSettle();

      // Assert TransactionDetailSheet is opened
      expect(find.byType(TransactionDetailSheet), findsOneWidget);
      expect(find.text('Transaction Details'), findsOneWidget);
    });

    testWidgets('Close icon dismisses CategoryTransactionsSheet cleanly', (tester) async {
      when(() => mockTxRepo.watchTransactionsByDateRange(any(), any()))
          .thenAnswer((_) => Stream.value(foodTxs));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionRepositoryProvider.overrideWithValue(mockTxRepo),
            categoryRepositoryProvider.overrideWithValue(mockCatRepo),
            categoriesStreamProvider.overrideWith((ref) => Stream.value([foodCategory])),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => CategoryTransactionsSheet.show(
                    context,
                    categoryId: 'cat_food',
                    categoryName: 'Food & Dining',
                    month: 8,
                    year: 2026,
                  ),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryTransactionsSheet), findsOneWidget);

      // Tap close button
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryTransactionsSheet), findsNothing);
    });
  });
}
