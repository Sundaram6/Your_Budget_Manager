import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/engine/recurring_engine.dart';
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

  group('RecurringEngine', () {
    test('processDueRecurring processes due items and updates dates correctly', () async {
      final now = DateTime.now();
      final todayStr = dateFormat.format(now);
      final yesterday = now.subtract(const Duration(days: 1));

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
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: now);
      expect(count, greaterThanOrEqualTo(1));

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_daily_1');
      expect(updated, isNotNull);
      expect(updated!.lastGeneratedDate, isNotNull);
      expect(dateFormat.format(updated.nextDueDate).compareTo(todayStr), greaterThan(0));

      final txs = await db.select(db.transactionsTable).get();
      expect(txs.isNotEmpty, isTrue);
      final generatedTx = txs.firstWhere((t) => t.recurringId == 'rec_daily_1');
      expect(generatedTx.amount, equals(250.0));
      expect(generatedTx.isRecurring, isTrue);
      expect(generatedTx.note, contains('[Auto-generated from recurring]'));
    });

    test('forceGenerate manually generates a transaction even when not due', () async {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 5));

      final rt = RecurringTransactionModel(
        id: 'rec_force_1',
        title: 'Gym Membership',
        amountPaise: 150000,
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
        notes: 'Gym fee',
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.forceGenerate('rec_force_1');
      expect(count, equals(1));

      final updated = await DatabaseHelper.instance.getRecurringTransactionById('rec_force_1');
      expect(updated, isNotNull);
      expect(updated!.lastGeneratedDate, isNotNull);

      final txs = await db.select(db.transactionsTable).get();
      expect(txs.any((t) => t.recurringId == 'rec_force_1'), isTrue);
    });

    test('processDueRecurring respects endDate limit', () async {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 10));

      final rt = RecurringTransactionModel(
        id: 'rec_ended_1',
        title: 'Expired Subscription',
        amountPaise: 50000,
        categoryId: 'cat_utilities',
        type: 'expense',
        frequency: 'daily',
        intervalDays: null,
        startDate: pastDate,
        endDate: pastDate.add(const Duration(days: 2)), // ended 8 days ago
        nextDueDate: pastDate,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: null,
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseHelper.instance.insertRecurringTransaction(rt);

      final count = await RecurringEngine.processDueRecurring(referenceDate: now);
      // Generated count should equal 3 (days 0, 1, 2) before breaking due to endDate
      expect(count, equals(3));
    });
  });
}
