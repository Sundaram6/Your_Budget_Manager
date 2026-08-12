import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:your_budget_manager/core/widgets/layout/empty_state.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/merchant/merchant_engine.dart';
import 'package:your_budget_manager/engines/sms/models/parsed_transaction.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';

void main() {
  late AppDatabase db;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late CategoryRepositoryImpl categoryRepo;
  late TransactionRepositoryImpl transactionRepo;
  late CategoryEngine categoryEngine;
  late ExpenseEngine expenseEngine;
  late MerchantEngine merchantEngine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    categoryDao = CategoryDao(db);
    transactionDao = TransactionDao(db);
    categoryRepo = CategoryRepositoryImpl(categoryDao);
    transactionRepo = TransactionRepositoryImpl(transactionDao);
    categoryEngine = CategoryEngine(categoryRepo);
    expenseEngine = ExpenseEngine(transactionRepo);
    merchantEngine = MerchantEngine(SmsQuery(), Logger(), expenseEngine);
  });

  tearDown(() async {
    await db.close();
  });

  group('Escalated Verification Protocol Tests', () {
    test('Fresh Install: seedDefaults seeds all 8 fixed category IDs and allows confirming non-Uncategorized transactions', () async {
      // 1. Seed defaults on fresh DB
      await categoryEngine.seedDefaults();

      // 2. Query categories directly from DB
      final dbCategories = await db.select(db.categoriesTable).get();
      final categoryIds = dbCategories.map((c) => c.id).toSet();

      final requiredFixedIds = [
        CategoryEngine.catGroceries,
        CategoryEngine.catShopping,
        CategoryEngine.catFood,
        CategoryEngine.catTransport,
        CategoryEngine.catUtilities,
        CategoryEngine.catEntertainment,
        CategoryEngine.catIncome,
        CategoryEngine.catUncategorized,
      ];

      for (final reqId in requiredFixedIds) {
        expect(categoryIds.contains(reqId), isTrue, reason: 'Missing category ID: $reqId in DB');
      }

      // 3. Confirm a pending transaction mapped to cat_groceries (Zepto/Blinkit)
      final pendingGroceriesTx = ParsedTransaction(
        smsId: 'sms-groceries-101',
        amount: 45000,
        merchantName: 'Zepto',
        merchantId: 'mer_zepto',
        sourceApp: 'sms:unknown',
        categoryId: CategoryEngine.catGroceries,
        originalSmsBody: 'Paid Rs 450 to Zepto for groceries',
        date: DateTime.now(),
      );

      final confirmed = await merchantEngine.confirmPendingTransaction(transaction: pendingGroceriesTx);
      expect(confirmed, isTrue);

      // 4. Direct DB Query verification: query transactions table directly
      final allDbTx = await transactionDao.watchAllTransactions().first;
      expect(allDbTx.length, equals(1));
      expect(allDbTx.first.categoryId, equals(CategoryEngine.catGroceries));
      expect(allDbTx.first.amount, equals(45000));
    });

    test('Existing/Stale Install Migration: remaps legacy dynamic UUID category foreign keys and inserts fixed IDs', () async {
      // 1. Simulate legacy DB pre-populated with dynamic UUID default category
      const oldLegacyUuid = 'legacy-uuid-groceries-999';
      await db.into(db.categoriesTable).insert(
        CategoriesTableCompanion.insert(
          id: oldLegacyUuid,
          name: 'Groceries',
          icon: 'cart',
          color: '4279286145',
          isDefault: const Value(true),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );


      // 2. Insert a legacy transaction linked to the old UUID
      await db.into(db.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          id: 'legacy-tx-1',
          amount: 25000,
          type: 'expense',
          categoryId: oldLegacyUuid,
          date: DateTime.now().millisecondsSinceEpoch,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // 3. Run seedDefaults (which triggers migration)
      await categoryEngine.seedDefaults();

      // 4. Verify old UUID is removed and fixed ID cat_groceries exists
      final dbCategories = await db.select(db.categoriesTable).get();
      final categoryIds = dbCategories.map((c) => c.id).toSet();

      expect(categoryIds.contains(oldLegacyUuid), isFalse);
      expect(categoryIds.contains(CategoryEngine.catGroceries), isTrue);

      // 5. Verify existing transaction FK was remapped to cat_groceries
      final allDbTx = await transactionDao.watchAllTransactions().first;
      expect(allDbTx.length, equals(1));
      expect(allDbTx.first.categoryId, equals(CategoryEngine.catGroceries));
    });

    testWidgets('EmptyState widget falls back to static icon without throwing red asset error when Lottie asset is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Empty State Title',
              subtitle: 'Empty State Subtitle',
              lottieAsset: 'assets/animations/non_existent_asset.json',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Empty State Title'), findsOneWidget);
      expect(find.text('Empty State Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
