import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/providers/database_providers.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/engine/recurring_engine.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('DB Ownership Consolidation Tests', () {
    late ProviderContainer container;
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(testDb),
        ],
      );
      // Explicitly trigger provider reading
      final db = container.read(appDatabaseProvider);
      DatabaseHelper.instance.setDatabase(db);
    });

    tearDown(() async {
      container.dispose();
      await testDb.close();
    });

    test('Canonical appDatabaseProvider is shared with DatabaseHelper.instance', () async {
      final providerDb = container.read(appDatabaseProvider);
      final helperDb = await DatabaseHelper.instance.db;

      expect(identical(providerDb, helperDb), isTrue,
          reason: 'DatabaseHelper.instance.db must resolve to the identical canonical AppDatabase instance provided by Riverpod');
      expect(identical(providerDb, testDb), isTrue);
    });

    test('All repository providers consume the exact same database instance', () async {
      final providerDb = container.read(appDatabaseProvider);
      final categoryRepo = container.read(categoryRepositoryProvider);
      final transactionRepo = container.read(transactionRepositoryProvider);
      final budgetRepo = container.read(budgetRepositoryProvider);
      final recurringRepo = container.read(recurringRepositoryProvider);
      final savingsRepo = container.read(savingsGoalRepositoryProvider);
      final savingsDao = container.read(savingsGoalDaoProvider);

      // Verify that all providers and repositories are operational on the single canonical DB
      expect(categoryRepo, isNotNull);
      expect(transactionRepo, isNotNull);
      expect(budgetRepo, isNotNull);
      expect(recurringRepo, isNotNull);
      expect(savingsRepo, isNotNull);
      expect(savingsDao, isNotNull);

      // Insert category directly through providerDb and verify immediate visibility through categoryRepo
      await providerDb.categoryDao.insertCategory(
        CategoriesTableCompanion.insert(
          id: 'test_cat_1',
          name: 'Utilities',
          icon: 'flash',
          color: '4294901760',
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );

      final categories = await categoryRepo.getCategories();
      expect(categories.length, 1);
      expect(categories.first.name, 'Utilities');
    });

    test('RecurringEngine writes to canonical DB instance via DatabaseHelper', () async {
      final providerDb = container.read(appDatabaseProvider);

      // Seed category
      await providerDb.categoryDao.insertCategory(
        CategoriesTableCompanion.insert(
          id: 'test_cat_rec',
          name: 'Bills',
          icon: 'receipt',
          color: '#00FF00',
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );

      // Insert recurring schedule via DatabaseHelper
      final rt = RecurringTransactionModel(
        id: 'rec_ownership_1',
        title: 'Electricity Bill',
        amountPaise: 150000,
        categoryId: 'test_cat_rec',
        type: 'expense',
        frequency: 'monthly',
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 2, 1),
        isActive: true,
        autoConfirm: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      // Verify it exists in canonical providerDb
      final allRecurring = await providerDb.recurringTransactionDao.getActive();
      expect(allRecurring.length, 1);
      expect(allRecurring.first.title, 'Electricity Bill');
      expect(allRecurring.first.amountPaise, 150000);

      // Process recurring through RecurringEngine and check that generated transactions land in canonical DB
      final count = await RecurringEngine.processDueRecurring(referenceDate: DateTime(2026, 2, 1));
      expect(count, 1);

      final txns = await providerDb.transactionDao.watchAllTransactions().first;
      expect(txns.length, 1);
      expect(txns.first.recurringId, 'rec_ownership_1');
    });
  });
}
