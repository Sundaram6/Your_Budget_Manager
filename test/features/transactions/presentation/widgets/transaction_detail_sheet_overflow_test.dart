import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/providers/database_providers.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/engines/transfer/self_transfer_engine.dart';
import 'package:your_budget_manager/engines/transfer/self_transfer_engine_provider.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/transaction_detail_sheet.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> transactions;
  FakeTransactionRepository([this.transactions = const []]);

  @override
  Future<List<Transaction>> getAllTransactions() async => transactions;

  @override
  Stream<List<Transaction>> watchAllTransactions() => Stream.value(transactions);

  @override
  Stream<List<Transaction>> watchTransactionsByCategory(String categoryId) => Stream.value(transactions);

  @override
  Stream<List<Transaction>> watchTransactionsByDateRange(DateTime start, DateTime end) => Stream.value(transactions);

  @override
  Future<int> insertTransaction(Transaction transaction) async => 1;

  @override
  Future<bool> updateTransaction(Transaction transaction) async => true;

  @override
  Future<int> deleteTransaction(Transaction transaction) async => 1;

  @override
  Future<Transaction?> getTransactionById(String id) async =>
      transactions.firstWhere((t) => t.id == id, orElse: () => transactions.first);
}

class FakeSelfTransferEngine implements SelfTransferEngine {
  bool unlinked = false;

  @override
  Future<void> unlinkPair(String transferPairId) async {
    unlinked = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final List<Category> testCategories = [
    const Category(
      id: 'cat_food',
      name: 'Food & Fine Dining and Delicious Takeout Restaurants',
      icon: 'restaurant',
      color: 0xFFFF5722,
      isDefault: true,
    ),
  ];

  final minimalTx = Transaction(
    id: 'tx-minimal',
    amount: const Amount(25000), // ₹250.00
    date: DateTime(2026, 8, 16, 10, 15),
    categoryId: 'cat_food',
    type: TransactionType.expense,
  );

  final maximalTx = Transaction(
    id: 'tx-maximal',
    amount: const Amount(98765432100), // ₹98,76,54,321.00
    date: DateTime(2026, 8, 16, 18, 45),
    categoryId: 'cat_food',
    type: TransactionType.expense,
    note: 'Weekly organic groceries from Nature Basket Superstore including imported artisanal cheese and bakery goods',
    paymentMethod: PaymentMethod.debit_card,
    accountLast4: '9876',
    transactionRef: 'UPI/20260816/987654321098/REF-TXN-ALPHA-OMEGA-999',
    transferPairId: 'tf_pair_alpha_123',
  );

  final viewports = [320.0, 360.0, 375.0, 390.0, 414.0];

  group('Phase 25: TransactionDetailSheet Pixel Overflow Tests', () {
    for (final width in viewports) {
      testWidgets('renders minimal transaction without overflow at width $width (Dark Theme)', (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        FlutterErrorDetails? caughtError;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          caughtError = details;
          originalOnError?.call(details);
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
              transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository([minimalTx])),
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
                        builder: (_) => TransactionDetailSheet(transaction: minimalTx),
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
        FlutterError.onError = originalOnError;

        expect(find.text('Transaction Details'), findsOneWidget);
        expect(find.text('₹250.00'), findsOneWidget);
        expect(find.text('Date & Time'), findsOneWidget);
        expect(caughtError, isNull);
      });

      testWidgets('renders maximal transaction with transfer badge and long metadata without overflow at width $width (Dark Theme)', (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        FlutterErrorDetails? caughtError;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          caughtError = details;
          originalOnError?.call(details);
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
              transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository([maximalTx])),
              selfTransferEngineProvider.overrideWithValue(FakeSelfTransferEngine()),
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
                        builder: (_) => TransactionDetailSheet(transaction: maximalTx),
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
        FlutterError.onError = originalOnError;

        expect(find.text('Transaction Details'), findsOneWidget);
        expect(find.text('Self Transfer'), findsOneWidget);
        expect(find.text('↔ ₹98,76,54,321.00'), findsOneWidget);
        expect(find.text('Linked Self-Transfer Pair'), findsOneWidget);
        expect(find.text('Unlink'), findsOneWidget);
        expect(find.text('Ref / UTR'), findsOneWidget);
        expect(find.text('Note'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
        expect(caughtError, isNull);
      });

      testWidgets('renders maximal transaction without overflow at width $width (Light Theme)', (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        FlutterErrorDetails? caughtError;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          caughtError = details;
          originalOnError?.call(details);
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
              transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository([maximalTx])),
              selfTransferEngineProvider.overrideWithValue(FakeSelfTransferEngine()),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => TransactionDetailSheet(transaction: maximalTx),
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
        FlutterError.onError = originalOnError;

        expect(find.text('Transaction Details'), findsOneWidget);
        expect(find.text('Self Transfer'), findsOneWidget);
        expect(find.text('↔ ₹98,76,54,321.00'), findsOneWidget);
        expect(caughtError, isNull);
      });
    }
  });

  group('Phase 25: TransactionDetailSheet Interactions Tests', () {
    testWidgets('Unlink transfer button triggers selfTransferEngine unlink', (WidgetTester tester) async {
      final fakeSelfTransfer = FakeSelfTransferEngine();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
            transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository([maximalTx])),
            selfTransferEngineProvider.overrideWithValue(fakeSelfTransfer),
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
                      builder: (_) => TransactionDetailSheet(transaction: maximalTx),
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

      expect(find.text('Unlink'), findsOneWidget);
      await tester.tap(find.text('Unlink'));
      await tester.pumpAndSettle();

      expect(fakeSelfTransfer.unlinked, isTrue);
      expect(find.text('Transfers unlinked successfully'), findsOneWidget);
    });

    testWidgets('Delete button prompts confirmation dialog and can be cancelled', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesStreamProvider.overrideWith((ref) => Stream.value(testCategories)),
            transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository([minimalTx])),
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
                      builder: (_) => TransactionDetailSheet(transaction: minimalTx),
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

      // Tap Delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Delete Transaction?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Transaction?'), findsNothing);
      expect(find.text('Transaction Details'), findsOneWidget);
    });
  });
}
