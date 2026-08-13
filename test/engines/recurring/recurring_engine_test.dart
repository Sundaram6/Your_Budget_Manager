import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/engines/recurring/recurring_engine.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';

void main() {
  late AppDatabase db;
  final dateFormat = DateFormat('yyyy-MM-dd');

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(db);
    await DatabaseHealthCheck(db).run();
  });

  tearDown(() async {
    await db.close();
  });

  group('Canonical RecurringEngine Tests', () {
    test('processDueRecurring processes single due item and advances nextDueDate', () async {
      final now = DateTime(2026, 6, 15);
      final yesterday = DateTime(2026, 6, 14);

      final rt = RecurringTransactionModel(
        id: 'rec_daily_1',
        title: 'Daily Coffee',
        amountPaise: 25000,
        categoryId: 'cat_food',
        type: 'expense',
        frequency: 'daily',
        intervalDays: null,
        startDate: yesterday,
        endDate: null,
        nextDueDate: yesterday,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: 'Coffee note',
        createdAt: yesterday,
        updatedAt: yesterday,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: now);
      // Yesterday and today -> 2 daily transactions generated
      expect(count, equals(2));

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_daily_1');
      expect(updated, isNotNull);
      expect(updated!.lastGeneratedDate, isNotNull);
      expect(dateFormat.format(updated.nextDueDate), equals('2026-06-16'));

      final txs = await db.select(db.transactionsTable).get();
      expect(txs.length, equals(2));
      final generatedTx = txs.firstWhere((t) => t.recurringId == 'rec_daily_1');
      expect(generatedTx.amount, equals(25000));
      expect(generatedTx.isRecurring, isTrue);
      expect(generatedTx.note, contains('[Auto-generated from recurring]'));
    });

    test('Catch-up multi-interval processing generates all missed occurrences', () async {
      // Scenario: User did not open app for 3 weeks (21 days) with a weekly schedule
      final referenceDate = DateTime(2026, 3, 22);
      final startDate = DateTime(2026, 3, 1);

      final rt = RecurringTransactionModel(
        id: 'rec_weekly_catchup',
        title: 'Weekly Groceries',
        amountPaise: 100000,
        categoryId: 'cat_food',
        type: 'expense',
        frequency: 'weekly',
        intervalDays: null,
        startDate: startDate,
        endDate: null,
        nextDueDate: startDate, // Due on Mar 1, Mar 8, Mar 15, Mar 22
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: 'Weekly staples',
        createdAt: startDate,
        updatedAt: startDate,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: referenceDate);
      // Expected: 4 transactions (Mar 1, Mar 8, Mar 15, Mar 22)
      expect(count, equals(4));

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_weekly_catchup')))
          .get();
      expect(txs.length, equals(4));

      final dates = txs.map((t) => DateTime.fromMillisecondsSinceEpoch(t.date)).toList();
      expect(dateFormat.format(dates[0]), equals('2026-03-01'));
      expect(dateFormat.format(dates[1]), equals('2026-03-08'));
      expect(dateFormat.format(dates[2]), equals('2026-03-15'));
      expect(dateFormat.format(dates[3]), equals('2026-03-22'));

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_weekly_catchup');
      expect(dateFormat.format(updated!.nextDueDate), equals('2026-03-29'));
    });

    test('Month-end clamping handles 31-day to 28/29-day transitions correctly without month overflow', () async {
      // Scenario: Started on Jan 31. Next due should be Feb 28, not Mar 2/3!
      final jan31 = DateTime(2026, 1, 31);
      final mar15 = DateTime(2026, 3, 15);

      final rt = RecurringTransactionModel(
        id: 'rec_monthly_clamp',
        title: 'Month-End Rent',
        amountPaise: 500000,
        categoryId: 'cat_utilities',
        type: 'expense',
        frequency: 'monthly',
        intervalDays: null,
        startDate: jan31,
        endDate: null,
        nextDueDate: jan31,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: 'Rent',
        createdAt: jan31,
        updatedAt: jan31,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: mar15);
      // Jan 31, Feb 28 -> 2 occurrences
      expect(count, equals(2));

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_monthly_clamp')))
          .get();
      expect(txs.length, equals(2));

      final dates = txs.map((t) => DateTime.fromMillisecondsSinceEpoch(t.date)).toList();
      expect(dateFormat.format(dates[0]), equals('2026-01-31'));
      expect(dateFormat.format(dates[1]), equals('2026-02-28')); // Clamped to Feb 28 in non-leap year

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_monthly_clamp');
      // Next due date in March restores 31st (month has 31 days - no anchor drift!)
      expect(dateFormat.format(updated!.nextDueDate), equals('2026-03-31'));
    });

    test('Leap year clamping handles Feb 29 safely for yearly schedules', () async {
      // Leap year 2024 to non-leap year 2025
      final feb29_2024 = DateTime(2024, 2, 29);
      final referenceDate = DateTime(2025, 3, 1);

      final rt = RecurringTransactionModel(
        id: 'rec_leap_yearly',
        title: 'Leap Day Anniversary',
        amountPaise: 200000,
        categoryId: 'cat_misc',
        type: 'expense',
        frequency: 'yearly',
        intervalDays: null,
        startDate: feb29_2024,
        endDate: null,
        nextDueDate: feb29_2024,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: 'Annual',
        createdAt: feb29_2024,
        updatedAt: feb29_2024,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: referenceDate);
      // 2024-02-29 and 2025-02-28 -> 2 occurrences
      expect(count, equals(2));

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_leap_yearly')))
          .get();
      expect(txs.length, equals(2));

      final dates = txs.map((t) => DateTime.fromMillisecondsSinceEpoch(t.date)).toList();
      expect(dateFormat.format(dates[0]), equals('2024-02-29'));
      expect(dateFormat.format(dates[1]), equals('2025-02-28'));
    });

    test('EndDate boundary stops generation when reached', () async {
      final now = DateTime(2026, 5, 20);
      final startDate = DateTime(2026, 5, 10);
      final endDate = DateTime(2026, 5, 12); // Only 3 days (10, 11, 12)

      final rt = RecurringTransactionModel(
        id: 'rec_ended_schedule',
        title: 'Temporary Subscription',
        amountPaise: 50000,
        categoryId: 'cat_entertainment',
        type: 'expense',
        frequency: 'daily',
        intervalDays: null,
        startDate: startDate,
        endDate: endDate,
        nextDueDate: startDate,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: null,
        createdAt: startDate,
        updatedAt: startDate,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: now);
      // Generated count must equal 3 (May 10, May 11, May 12) and stop
      expect(count, equals(3));

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_ended_schedule')))
          .get();
      expect(txs.length, equals(3));
    });

    test('Custom frequency with intervalDays generates on exact interval', () async {
      final startDate = DateTime(2026, 4, 1);
      final referenceDate = DateTime(2026, 4, 25);

      final rt = RecurringTransactionModel(
        id: 'rec_custom_interval',
        title: 'Every 10 Days',
        amountPaise: 30000,
        categoryId: 'cat_utilities',
        type: 'expense',
        frequency: 'custom',
        intervalDays: 10,
        startDate: startDate,
        endDate: null,
        nextDueDate: startDate,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: '10 day interval',
        createdAt: startDate,
        updatedAt: startDate,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: referenceDate);
      // Apr 1, Apr 11, Apr 21 -> 3 occurrences
      expect(count, equals(3));

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_custom_interval');
      expect(dateFormat.format(updated!.nextDueDate), equals('2026-05-01'));
    });

    test('Biweekly frequency advances by 14 days', () async {
      final startDate = DateTime(2026, 7, 1);
      final referenceDate = DateTime(2026, 7, 20);

      final rt = RecurringTransactionModel(
        id: 'rec_biweekly',
        title: 'Biweekly Salary Advance',
        amountPaise: 80000,
        categoryId: 'cat_income',
        type: 'income',
        frequency: 'biweekly',
        intervalDays: null,
        startDate: startDate,
        endDate: null,
        nextDueDate: startDate,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: true,
        notes: 'Biweekly paycheck',
        createdAt: startDate,
        updatedAt: startDate,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: referenceDate);
      // Jul 1, Jul 15 -> 2 occurrences
      expect(count, equals(2));

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_biweekly');
      expect(dateFormat.format(updated!.nextDueDate), equals('2026-07-29'));
    });

    test('Inactive (paused) recurring schedules are ignored by processDueRecurring', () async {
      final now = DateTime(2026, 8, 1);
      final pastDate = DateTime(2026, 7, 1);

      final rt = RecurringTransactionModel(
        id: 'rec_paused',
        title: 'Paused Gym',
        amountPaise: 150000,
        categoryId: 'cat_health',
        type: 'expense',
        frequency: 'monthly',
        intervalDays: null,
        startDate: pastDate,
        endDate: null,
        nextDueDate: pastDate,
        lastGeneratedDate: null,
        isActive: false, // PAUSED
        autoConfirm: false,
        notes: 'Paused subscription',
        createdAt: pastDate,
        updatedAt: pastDate,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: now);
      expect(count, equals(0));

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_paused')))
          .get();
      expect(txs.isEmpty, isTrue);
    });

    test('forceGenerate manually generates a transaction even when nextDueDate is in the future', () async {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 10));

      final rt = RecurringTransactionModel(
        id: 'rec_force_manual',
        title: 'Advance Electricity Payment',
        amountPaise: 120000,
        categoryId: 'cat_utilities',
        type: 'expense',
        frequency: 'monthly',
        intervalDays: null,
        startDate: futureDate,
        endDate: null,
        nextDueDate: futureDate,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: 'Pre-paid',
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.forceGenerate('rec_force_manual');
      expect(count, equals(1));

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_force_manual');
      expect(updated, isNotNull);
      expect(updated!.lastGeneratedDate, isNotNull);

      final txs = await (db.select(db.transactionsTable)
            ..where((t) => t.recurringId.equals('rec_force_manual')))
          .get();
      expect(txs.length, equals(1));
      expect(txs.first.amount, equals(120000));
    });

    test('Instance methods of RecurringEngine work seamlessly for DI and Riverpod callers', () async {
      const engine = RecurringEngine();
      final now = DateTime(2026, 9, 1);

      final rt = RecurringTransactionModel(
        id: 'rec_instance_test',
        title: 'Internet Fiber',
        amountPaise: 99900,
        categoryId: 'cat_utilities',
        type: 'expense',
        frequency: 'monthly',
        intervalDays: null,
        startDate: now,
        endDate: null,
        nextDueDate: now,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: 'Broadband',
        createdAt: now,
        updatedAt: now,
      );

      // Add via instance method
      await engine.addRecurring(rt);

      // Watch via instance method
      final list = await engine.watchAll().first;
      expect(list.any((r) => r.id == 'rec_instance_test'), isTrue);

      // Process via instance method
      final processedCount = await engine.processDueTransactions(referenceDate: now);
      expect(processedCount, equals(1));

      // Delete via instance method
      await engine.deleteRecurring('rec_instance_test');
      final listAfterDelete = await engine.watchAll().first;
      expect(listAfterDelete.any((r) => r.id == 'rec_instance_test'), isFalse);
    });
  });
}
