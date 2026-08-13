import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/errors/app_exception.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/savings_goal_dao.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/recurring/recurring_engine.dart';
import 'package:your_budget_manager/engines/savings/savings_engine.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';
import 'package:your_budget_manager/models/transaction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SavingsGoalDao savingsGoalDao;
  late SavingsEngine savingsEngine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(db);

    // Seed default categories
    for (final cat in [
      CategoryEngine.catGroceries,
      CategoryEngine.catShopping,
      CategoryEngine.catFood,
      CategoryEngine.catTransport,
      CategoryEngine.catUtilities,
      CategoryEngine.catEntertainment,
      CategoryEngine.catIncome,
      CategoryEngine.catUncategorized,
    ]) {
      await db.into(db.categoriesTable).insert(
        Category(
          id: cat,
          name: cat,
          icon: 'category',
          color: '#000000',
          isDefault: true,
          sortOrder: 0,
          createdAt: 1000,
          updatedAt: 1000,
        ),
        mode: drift.InsertMode.insertOrIgnore,
      );
    }

    savingsGoalDao = SavingsGoalDao(db);
    savingsEngine = SavingsEngine(savingsGoalDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 7: Financial Integrity - Recurring Engine Atomicity & Idempotency', () {
    test('generateRecurringOccurrence idempotency: retry with same occurrence key does not duplicate transaction', () async {
      final now = DateTime.now();
      final rt = RecurringTransactionModel(
        id: 'rec_sub_1',
        title: 'Monthly Subscription',
        amountPaise: 50000,
        categoryId: CategoryEngine.catUncategorized,
        type: 'expense',
        frequency: 'monthly',
        startDate: DateTime(2026, 8, 1),
        nextDueDate: DateTime(2026, 8, 1),
        createdAt: now,
        updatedAt: now,
      );
      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final tx = TransactionModel(
        id: 'tx_rec_101',
        title: 'Monthly Subscription',
        amountPaise: 50000,
        categoryId: CategoryEngine.catUncategorized,
        type: 'expense',
        date: DateTime(2026, 8, 1),
        notes: 'Netflix [Auto-generated from recurring]',
        isRecurring: true,
        recurringId: 'rec_sub_1',
        recurrenceOccurrenceKey: 'rec_sub_1:2026-08-01',
        createdAt: now,
      );

      // 1. Initial generation
      final firstInsert = await DatabaseHelper.instance.generateRecurringOccurrence(
        transaction: tx,
        occurrenceKey: 'rec_sub_1:2026-08-01',
        recurringId: 'rec_sub_1',
        nextDueDate: '2026-09-01',
        lastGeneratedDate: '2026-08-01',
        updatedAt: now.toIso8601String(),
      );
      expect(firstInsert, isTrue);

      final countAfterFirst = await (db.select(db.transactionsTable)
            ..where((t) => t.recurrenceOccurrenceKey.equals('rec_sub_1:2026-08-01')))
          .get();
      expect(countAfterFirst.length, equals(1));

      // 2. Retry with same occurrenceKey (simulating catch-up retry after crash)
      final duplicateTx = tx.copyWith(id: 'tx_rec_102_retry');
      final secondInsert = await DatabaseHelper.instance.generateRecurringOccurrence(
        transaction: duplicateTx,
        occurrenceKey: 'rec_sub_1:2026-08-01',
        recurringId: 'rec_sub_1',
        nextDueDate: '2026-09-01',
        lastGeneratedDate: '2026-08-01',
        updatedAt: now.toIso8601String(),
      );

      expect(secondInsert, isFalse, reason: 'Duplicate occurrence must be skipped');

      final countAfterRetry = await (db.select(db.transactionsTable)
            ..where((t) => t.recurrenceOccurrenceKey.equals('rec_sub_1:2026-08-01')))
          .get();
      expect(countAfterRetry.length, equals(1), reason: 'Zero duplicate rows must be created in transactions table');
      expect(countAfterRetry.first.id, equals('tx_rec_101'));
    });

    test('Recurring catch-up processing generates exactly one transaction per occurrence key', () async {
      final rt = RecurringTransactionModel(
        id: 'rec_rent_1',
        title: 'House Rent',
        amountPaise: 2500000,
        categoryId: CategoryEngine.catUncategorized,
        type: 'expense',
        frequency: 'monthly',
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      // Catch-up to April 1st, 2026 (Jan 1, Feb 1, Mar 1, Apr 1 = 4 occurrences)
      final generatedCount = await RecurringEngine.processDueRecurring(
        referenceDate: DateTime(2026, 4, 1),
      );
      expect(generatedCount, equals(4));

      final allTx = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_rent_1')))
          .get();
      expect(allTx.length, equals(4));

      // Re-running processDueRecurring on the same day generates 0 additional transactions
      final reRunCount = await RecurringEngine.processDueRecurring(
        referenceDate: DateTime(2026, 4, 1),
      );
      expect(reRunCount, equals(0));

      final allTxAfter = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_rent_1')))
          .get();
      expect(allTxAfter.length, equals(4));
    });
  });

  group('Phase 7: Financial Integrity - Monthly Anchor Drift & Leap-Year Policy', () {
    test('Monthly recurrence starting on Jan 31 maintains 31st anchor across short and long months', () async {
      final rt = RecurringTransactionModel(
        id: 'rec_gym_31',
        title: 'Gym Membership',
        amountPaise: 300000,
        categoryId: CategoryEngine.catUncategorized,
        type: 'expense',
        frequency: 'monthly',
        startDate: DateTime(2026, 1, 31),
        nextDueDate: DateTime(2026, 1, 31),
        createdAt: DateTime(2026, 1, 31),
        updatedAt: DateTime(2026, 1, 31),
      );
      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      // Catch-up across 5 months through May 31, 2026
      final generated = await RecurringEngine.processDueRecurring(
        referenceDate: DateTime(2026, 5, 31),
      );
      expect(generated, equals(5));

      final txList = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_gym_31'))
            ..orderBy([(t) => drift.OrderingTerm.asc(t.date)]))
          .get();

      expect(txList.length, equals(5));

      // 1. Jan 31, 2026
      expect(DateTime.fromMillisecondsSinceEpoch(txList[0].date), equals(DateTime(2026, 1, 31)));
      // 2. Feb 28, 2026 (clamped to 28)
      expect(DateTime.fromMillisecondsSinceEpoch(txList[1].date), equals(DateTime(2026, 2, 28)));
      // 3. Mar 31, 2026 (restored to 31 - NO ANCHOR DRIFT!)
      expect(DateTime.fromMillisecondsSinceEpoch(txList[2].date), equals(DateTime(2026, 3, 31)));
      // 4. Apr 30, 2026 (clamped to 30)
      expect(DateTime.fromMillisecondsSinceEpoch(txList[3].date), equals(DateTime(2026, 4, 30)));
      // 5. May 31, 2026 (restored to 31 - NO ANCHOR DRIFT!)
      expect(DateTime.fromMillisecondsSinceEpoch(txList[4].date), equals(DateTime(2026, 5, 31)));

      // Check updated recurring schedule next_due_date is 2026-06-30 (June has 30 days)
      final updatedRt = await DatabaseHelper.instance.getRecurringTransactionById('rec_gym_31');
      expect(updatedRt!.nextDueDate, equals(DateTime(2026, 6, 30)));
    });

    test('Yearly leap-day recurrence on Feb 29 clamps to Feb 28 in common years and restores Feb 29 in leap years', () async {
      final rt = RecurringTransactionModel(
        id: 'rec_leap_1',
        title: 'Leap Day Insurance',
        amountPaise: 1200000,
        categoryId: CategoryEngine.catUncategorized,
        type: 'expense',
        frequency: 'yearly',
        startDate: DateTime(2024, 2, 29),
        nextDueDate: DateTime(2024, 2, 29),
        createdAt: DateTime(2024, 2, 29),
        updatedAt: DateTime(2024, 2, 29),
      );
      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      // Process through 2028 (5 years: 2024, 2025, 2026, 2027, 2028)
      final generated = await RecurringEngine.processDueRecurring(
        referenceDate: DateTime(2028, 3, 1),
      );
      expect(generated, equals(5));

      final txList = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_leap_1'))
            ..orderBy([(t) => drift.OrderingTerm.asc(t.date)]))
          .get();

      expect(txList.length, equals(5));
      expect(DateTime.fromMillisecondsSinceEpoch(txList[0].date), equals(DateTime(2024, 2, 29))); // Leap year
      expect(DateTime.fromMillisecondsSinceEpoch(txList[1].date), equals(DateTime(2025, 2, 28))); // Common year
      expect(DateTime.fromMillisecondsSinceEpoch(txList[2].date), equals(DateTime(2026, 2, 28))); // Common year
      expect(DateTime.fromMillisecondsSinceEpoch(txList[3].date), equals(DateTime(2027, 2, 28))); // Common year
      expect(DateTime.fromMillisecondsSinceEpoch(txList[4].date), equals(DateTime(2028, 2, 29))); // Leap year
    });
  });

  group('Phase 7: Financial Integrity - Invalid Recurrence Guards', () {
    test('Custom frequency with intervalDays <= 0 throws ValidationException and does NOT generate transactions', () async {
      final rtInvalid = RecurringTransactionModel(
        id: 'rec_invalid_interval',
        title: 'Broken Custom',
        amountPaise: 10000,
        categoryId: CategoryEngine.catUncategorized,
        type: 'expense',
        frequency: 'custom',
        intervalDays: 0,
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      await DatabaseHelper.instance.insertRecurringTransaction(rtInvalid);

      final count = await RecurringEngine.processDueRecurring(
        referenceDate: DateTime(2026, 2, 1),
      );
      expect(count, equals(0), reason: 'Corrupt recurrence item must be skipped without generating transactions');

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_invalid_interval')))
          .get();
      expect(txs, isEmpty);
    });

    test('Unknown frequency throws ValidationException and does NOT default to daily', () async {
      final rtUnknown = RecurringTransactionModel(
        id: 'rec_unknown_freq',
        title: 'Broken Unknown Frequency',
        amountPaise: 10000,
        categoryId: CategoryEngine.catUncategorized,
        type: 'expense',
        frequency: 'bi-monthly_unknown',
        startDate: DateTime(2026, 1, 1),
        nextDueDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      await DatabaseHelper.instance.insertRecurringTransaction(rtUnknown);

      final count = await RecurringEngine.processDueRecurring(
        referenceDate: DateTime(2026, 1, 10),
      );
      expect(count, equals(0), reason: 'Unknown frequency must NOT fall back to daily transactions');

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_unknown_freq')))
          .get();
      expect(txs, isEmpty);
    });
  });

  group('Phase 7: Financial Integrity - Savings Runtime Validation', () {
    test('createGoal throws ValidationException on empty name and non-positive targetAmount', () async {
      expect(
        () => savingsEngine.createGoal(name: '', targetAmountPaise: 50000),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => savingsEngine.createGoal(name: '   ', targetAmountPaise: 50000),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => savingsEngine.createGoal(name: 'New Car', targetAmountPaise: 0),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => savingsEngine.createGoal(name: 'New Car', targetAmountPaise: -5000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('contributeToGoal throws ValidationException on non-positive amount', () async {
      await savingsEngine.createGoal(name: 'Emergency Fund', targetAmountPaise: 100000);
      final goals = await savingsGoalDao.getAll();
      final goalId = goals.first.id;

      expect(
        () => savingsEngine.contributeToGoal(goalId, 0),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => savingsEngine.contributeToGoal(goalId, -100),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Phase 7: Financial Integrity - Atomic Savings Mutations & Auto-Deduction Races', () {
    test('Concurrent deposit calls sum accurately via atomic transactions', () async {
      await savingsEngine.createGoal(name: 'Vacation', targetAmountPaise: 1000000);
      final goals = await savingsGoalDao.getAll();
      final goalId = goals.first.id;

      // Simulate 10 simultaneous concurrent deposits of ₹100 (10,000 paise) each
      await Future.wait(
        List.generate(10, (_) => savingsEngine.contributeToGoal(goalId, 10000)),
      );

      final updated = await savingsGoalDao.getById(goalId);
      expect(updated!.currentAmount, equals(100000), reason: 'All 10 concurrent deposits must sum without lost updates');
    });

    test('Concurrent auto-deduction calls for the same month apply exactly once', () async {
      await db.into(db.budgetsTable).insert(
        BudgetsTableCompanion.insert(
          id: 'b_main',
          amount: 100000,
          month: 8,
          year: 2026,
          createdAt: 1000,
        ),
        mode: drift.InsertMode.insertOrIgnore,
      );

      await savingsEngine.createGoal(
        name: 'Auto SIP',
        targetAmountPaise: 5000000,
        linkedBudgetId: 'b_main',
        autoDeduct: true,
        autoDeductAmountPaise: 50000, // ₹500
      );

      // Execute 5 concurrent auto-deductions simultaneously
      await Future.wait([
        savingsEngine.executeAutoDeductions('b_main'),
        savingsEngine.executeAutoDeductions('b_main'),
        savingsEngine.executeAutoDeductions('b_main'),
        savingsEngine.executeAutoDeductions('b_main'),
        savingsEngine.executeAutoDeductions('b_main'),
      ]);

      final goals = await savingsGoalDao.getAll();
      final goal = goals.first;

      expect(goal.currentAmount, equals(50000), reason: 'Auto-deduction must apply exactly once per month even under concurrent triggers');
      expect(goal.lastAutoDeductedMonth, isNotNull);
    });
  });
}
