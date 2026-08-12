import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
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
  late DatabaseHealthCheck healthCheck;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    categoryDao = CategoryDao(db);
    transactionDao = TransactionDao(db);
    categoryRepo = CategoryRepositoryImpl(categoryDao);
    transactionRepo = TransactionRepositoryImpl(transactionDao);
    categoryEngine = CategoryEngine(categoryRepo);
    expenseEngine = ExpenseEngine(transactionRepo);
    healthCheck = DatabaseHealthCheck(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Stale Device Migration & Auto-Default Integration Test', () {
    test('Migrates stale device DB with old dynamic UUID categories and auto-defaults manual expense without category selection', () async {
      // 1. Seed stale DB with old random-UUID categories (isDefault: true)
      const oldGroceriesUuid = 'a1b2c3d4-groceries-uuid';
      await db.into(db.categoriesTable).insert(
        CategoriesTableCompanion.insert(
          id: oldGroceriesUuid,
          name: 'Groceries',
          icon: 'cart',
          color: '4279286145',
          isDefault: const Value(true),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Link an existing transaction to old Groceries UUID
      await db.into(db.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          id: 'old-tx-101',
          amount: 32000,
          type: 'expense',
          categoryId: oldGroceriesUuid,
          date: DateTime.now().millisecondsSinceEpoch,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // 2. Launch cold start health check & seedDefaults
      await healthCheck.run();
      await categoryEngine.seedDefaults();

      // 3. Verify old UUID category is deleted and fixed cat_groceries exists
      final allCategories = await db.select(db.categoriesTable).get();
      final categoryIds = allCategories.map((c) => c.id).toSet();

      expect(categoryIds.contains(oldGroceriesUuid), isFalse);
      expect(categoryIds.contains(CategoryEngine.catGroceries), isTrue);
      expect(categoryIds.contains(CategoryEngine.catUncategorized), isTrue);

      // 4. Verify existing transaction FK was remapped to cat_groceries
      final remappedTxList = await transactionDao.watchAllTransactions().first;
      expect(remappedTxList.length, equals(1));
      expect(remappedTxList.first.categoryId, equals(CategoryEngine.catGroceries));

      // 5. Test manual expense submission without selecting a category (auto-defaults to cat_uncategorized)
      final manualTx = await expenseEngine.addTransaction(
        amount: 15000,
        date: DateTime.now(),
        categoryId: CategoryEngine.catUncategorized,
        type: TransactionType.expense,
        note: 'Manual Expense Without Category Picker',
      );

      expect(manualTx.categoryId, equals(CategoryEngine.catUncategorized));

      // Query database directly to confirm persistence
      final allTxAfterManual = await transactionDao.watchAllTransactions().first;
      expect(allTxAfterManual.length, equals(2));
      final addedManual = allTxAfterManual.firstWhere((t) => t.id == manualTx.id);
      expect(addedManual.categoryId, equals(CategoryEngine.catUncategorized));
    });
  });
}
