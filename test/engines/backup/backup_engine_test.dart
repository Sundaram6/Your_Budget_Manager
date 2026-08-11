import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/security/encryption_service.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';

void main() {
  late AppDatabase db;
  late BackupEngine backupEngine;
  const passphrase = 'test_passphrase';

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backupEngine = BackupEngine(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('exportData and importData should round-trip correctly across all tables including savings_goals', () async {
    // Insert prerequisite categories and budgets
    const category = Category(
      id: 'cat-1',
      name: 'Food',
      icon: 'food_icon',
      color: '#000000',
      isDefault: false,
      sortOrder: 0,
      createdAt: 1000,
      updatedAt: 1000,
    );
    await db.into(db.categoriesTable).insert(category);

    const merchant = Merchant(
      id: 'merch-1',
      name: 'Supermarket',
      icon: 'supermarket_icon',
      createdAt: 1000,
      updatedAt: 1000,
    );
    await db.into(db.merchantsTable).insert(merchant);

    const budget = Budget(
      id: 'budget-1',
      name: 'Monthly Budget',
      categoryId: 'cat-1',
      amount: 2000000,
      month: 8,
      year: 2026,
      createdAt: 1000,
      type: 'monthly',
    );
    await db.into(db.budgetsTable).insert(budget);

    const recurring = RecurringTransactionData(
      id: 'rec-1',
      title: 'Netflix',
      amountPaise: 64900,
      categoryId: 'cat-1',
      type: 'expense',
      frequency: 'monthly',
      intervalDays: null,
      startDate: '2026-01-01',
      endDate: null,
      nextDueDate: '2026-09-01',
      lastGeneratedDate: null,
      isActive: true,
      autoConfirm: false,
      notes: 'Sub',
      createdAt: '2026-01-01T00:00:00.000',
      updatedAt: '2026-01-01T00:00:00.000',
    );
    await db.into(db.recurringTransactionsTable).insert(recurring);

    const savingsGoal1 = SavingsGoal(
      id: 'goal-1',
      name: 'Emergency Fund',
      targetAmount: 5000000,
      currentAmount: 1500000,
      deadline: 1785872022000,
      budgetId: 'budget-1',
      autoDeduct: true,
      autoDeductAmount: 100000,
      lastAutoDeductedMonth: '2026-08',
      categoryId: 'cat-1',
      targetDate: 1785872022000,
      startDate: 1704067200000,
      status: 'active',
      iconName: 'savings',
      colorHex: '#FFD700',
      note: '6 months of living expenses',
      createdAt: 1704067200000,
      updatedAt: 1704067200000,
    );
    const savingsGoal2 = SavingsGoal(
      id: 'goal-2',
      name: 'Vacation',
      targetAmount: 1000000,
      currentAmount: 200000,
      deadline: null,
      budgetId: null,
      autoDeduct: false,
      autoDeductAmount: null,
      lastAutoDeductedMonth: null,
      categoryId: null,
      targetDate: null,
      startDate: 1704067200000,
      status: 'active',
      iconName: 'flight',
      colorHex: '#4CAF50',
      note: null,
      createdAt: 1704067200000,
      updatedAt: 1704067200000,
    );
    await db.into(db.savingsGoalsTable).insert(savingsGoal1);
    await db.into(db.savingsGoalsTable).insert(savingsGoal2);

    const transaction = Transaction(
      id: 'txn-1',
      amount: 150.0,
      type: 'expense',
      categoryId: 'cat-1',
      date: 1704067200000,
      note: 'Lunch',
      merchantName: 'Supermarket',
      merchantId: 'merch-1',
      isRecurring: false,
      recurringId: null,
      isAutoCaptured: false,
      sourceApp: null,
      createdAt: 1000,
      updatedAt: 1000,
    );
    await db.into(db.transactionsTable).insert(transaction);

    // Export data
    final encryptedData = await backupEngine.exportData(passphrase);
    expect(encryptedData, isNotEmpty);

    // Restore into a completely fresh database instance
    final freshDb = AppDatabase(NativeDatabase.memory());
    final freshBackupEngine = BackupEngine(freshDb);

    try {
      await freshBackupEngine.importData(encryptedData, passphrase);

      // Verify all tables restored
      final cats = await freshDb.select(freshDb.categoriesTable).get();
      expect(cats.length, 1);
      expect(cats.first.name, 'Food');

      final merchants = await freshDb.select(freshDb.merchantsTable).get();
      expect(merchants.length, 1);
      expect(merchants.first.name, 'Supermarket');

      final budgets = await freshDb.select(freshDb.budgetsTable).get();
      expect(budgets.length, 1);
      expect(budgets.first.name, 'Monthly Budget');
      expect(budgets.first.amount, 2000000);

      final recs = await freshDb.select(freshDb.recurringTransactionsTable).get();
      expect(recs.length, 1);
      expect(recs.first.title, 'Netflix');
      expect(recs.first.amountPaise, 64900);

      final txns = await freshDb.select(freshDb.transactionsTable).get();
      expect(txns.length, 1);
      expect(txns.first.id, 'txn-1');
      expect(txns.first.amount, 150.0);

      // Verify savings goals fully restored with all nullable & non-nullable fields
      final goals = await freshDb.select(freshDb.savingsGoalsTable).get();
      expect(goals.length, 2);

      final g1 = goals.firstWhere((g) => g.id == 'goal-1');
      expect(g1.name, 'Emergency Fund');
      expect(g1.targetAmount, 5000000);
      expect(g1.currentAmount, 1500000);
      expect(g1.deadline, 1785872022000);
      expect(g1.budgetId, 'budget-1');
      expect(g1.autoDeduct, true);
      expect(g1.autoDeductAmount, 100000);
      expect(g1.lastAutoDeductedMonth, '2026-08');
      expect(g1.categoryId, 'cat-1');
      expect(g1.targetDate, 1785872022000);
      expect(g1.startDate, 1704067200000);
      expect(g1.status, 'active');
      expect(g1.iconName, 'savings');
      expect(g1.colorHex, '#FFD700');
      expect(g1.note, '6 months of living expenses');
      expect(g1.createdAt, 1704067200000);
      expect(g1.updatedAt, 1704067200000);

      final g2 = goals.firstWhere((g) => g.id == 'goal-2');
      expect(g2.name, 'Vacation');
      expect(g2.targetAmount, 1000000);
      expect(g2.currentAmount, 200000);
      expect(g2.deadline, isNull);
      expect(g2.budgetId, isNull);
      expect(g2.autoDeduct, false);
      expect(g2.autoDeductAmount, isNull);
      expect(g2.lastAutoDeductedMonth, isNull);
      expect(g2.categoryId, isNull);
      expect(g2.targetDate, isNull);
      expect(g2.startDate, 1704067200000);
      expect(g2.status, 'active');
      expect(g2.iconName, 'flight');
      expect(g2.colorHex, '#4CAF50');
      expect(g2.note, isNull);
      expect(g2.createdAt, 1704067200000);
      expect(g2.updatedAt, 1704067200000);
    } finally {
      await freshDb.close();
    }
  });

  test('importData handles legacy backup missing savings_goals gracefully', () async {
    final payload = {
      'formatVersion': 1,
      'appVersion': '1.0.0',
      'exportedAt': 1735689600,
      'dbSchemaVersion': 1,
      'data': {
        // savingsGoals and merchants missing (legacy backup)
        'categories': [
          {
            'id': 'cat-2',
            'name': 'Transport',
            'icon': 'car',
            'color': '#123456',
            'isDefault': false,
            'sortOrder': 0,
            'createdAt': 1000,
            'updatedAt': 1000,
          }
        ]
      }
    };

    final bytes = utf8.encode(passphrase);
    final key = base64.encode(sha256.convert(bytes).bytes);
    final encryptionService = EncryptionService(key);
    final encryptedData = encryptionService.encrypt(jsonEncode(payload));

    await backupEngine.importData(encryptedData, passphrase);

    final cats = await db.select(db.categoriesTable).get();
    expect(cats.length, 1);
    expect(cats.first.name, 'Transport');

    final merchants = await db.select(db.merchantsTable).get();
    expect(merchants, isEmpty);

    final goals = await db.select(db.savingsGoalsTable).get();
    expect(goals, isEmpty);
  });

  test('importData throws on unknown future formatVersion', () async {
    final payload = {
      'formatVersion': 2,
      'appVersion': '2.0.0',
      'data': {}
    };

    final bytes = utf8.encode(passphrase);
    final key = base64.encode(sha256.convert(bytes).bytes);
    final encryptionService = EncryptionService(key);
    final encryptedData = encryptionService.encrypt(jsonEncode(payload));

    expect(
      () => backupEngine.importData(encryptedData, passphrase),
      throwsA(isA<Exception>()),
    );
  });
}
