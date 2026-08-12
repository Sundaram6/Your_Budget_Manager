import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/errors/app_exception.dart';
import 'package:your_budget_manager/core/security/encryption_service.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';

void main() {
  late AppDatabase db;
  late BackupEngine backupEngine;
  const passphrase = 'test_secure_passphrase_123';

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

  group('BackupEngine - v2 PBKDF2 Encryption & Savings Goals Completeness', () {
    test('exportData produces a v2 envelope with PBKDF2 salt, iv, ciphertext, and HMAC', () async {
      final encryptedData = await backupEngine.exportData(passphrase);
      
      expect(encryptedData, startsWith('v2:'));
      final parts = encryptedData.split(':');
      expect(parts.length, 5, reason: 'v2 envelope must have 5 colon-separated components');
      expect(parts[0], 'v2');
      // Salt (16 bytes = 24 base64 chars)
      expect(base64.decode(parts[1]).length, 16);
      // IV (16 bytes = 24 base64 chars)
      expect(base64.decode(parts[2]).length, 16);
      // Ciphertext
      expect(base64.decode(parts[3]).length, greaterThan(0));
      // HMAC-SHA256 (32 bytes = 44 base64 chars)
      expect(base64.decode(parts[4]).length, 32);
    });

    test('exportData and importData preserves all savings goal fields and relationships with deep equality', () async {
      const category = Category(
        id: 'cat-savings',
        name: 'Savings & Investments',
        icon: 'piggy_bank',
        color: '#4CAF50',
        isDefault: false,
        sortOrder: 0,
        createdAt: 1700000000000,
        updatedAt: 1700000000000,
      );
      await db.into(db.categoriesTable).insert(category);

      const budget = Budget(
        id: 'budget-savings-1',
        name: 'Monthly Savings Plan',
        categoryId: 'cat-savings',
        amount: 5000000,
        month: 8,
        year: 2026,
        createdAt: 1700000000000,
        type: 'monthly',
      );
      await db.into(db.budgetsTable).insert(budget);

      // Goal 1: Active auto-deduction with linked budget & category
      const savingsGoal1 = SavingsGoal(
        id: 'goal-emergency-fund',
        name: 'Emergency Fund',
        targetAmount: 50000000, // ₹500,000 in paise
        currentAmount: 15000000, // ₹150,000 in paise (contributions deposited)
        deadline: 1785872022000,
        budgetId: 'budget-savings-1',
        autoDeduct: true,
        autoDeductAmount: 1000000, // ₹10,000/month auto-deduct
        lastAutoDeductedMonth: '2026-08',
        categoryId: 'cat-savings',
        targetDate: 1785872022000,
        startDate: 1704067200000,
        status: 'active',
        iconName: 'savings',
        colorHex: '#FFD700',
        note: '6 months of living expenses buffer',
        createdAt: 1704067200000,
        updatedAt: 1704067200000,
      );

      // Goal 2: Manual contributions with null deadline/budget
      const savingsGoal2 = SavingsGoal(
        id: 'goal-vacation',
        name: 'Europe Trip',
        targetAmount: 20000000,
        currentAmount: 5000000,
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
        colorHex: '#2196F3',
        note: null,
        createdAt: 1704067200000,
        updatedAt: 1704067200000,
      );

      await db.into(db.savingsGoalsTable).insert(savingsGoal1);
      await db.into(db.savingsGoalsTable).insert(savingsGoal2);

      // Export
      final encryptedData = await backupEngine.exportData(passphrase);
      expect(encryptedData, isNotEmpty);

      // Restore into fresh DB
      final freshDb = AppDatabase(NativeDatabase.memory());
      final freshBackupEngine = BackupEngine(freshDb);

      try {
        await freshBackupEngine.importData(encryptedData, passphrase);

        final restoredGoals = await freshDb.select(freshDb.savingsGoalsTable).get();
        expect(restoredGoals.length, 2);

        final g1 = restoredGoals.firstWhere((g) => g.id == 'goal-emergency-fund');
        expect(g1.name, savingsGoal1.name);
        expect(g1.targetAmount, savingsGoal1.targetAmount);
        expect(g1.currentAmount, savingsGoal1.currentAmount);
        expect(g1.deadline, savingsGoal1.deadline);
        expect(g1.budgetId, savingsGoal1.budgetId);
        expect(g1.autoDeduct, savingsGoal1.autoDeduct);
        expect(g1.autoDeductAmount, savingsGoal1.autoDeductAmount);
        expect(g1.lastAutoDeductedMonth, savingsGoal1.lastAutoDeductedMonth);
        expect(g1.categoryId, savingsGoal1.categoryId);
        expect(g1.targetDate, savingsGoal1.targetDate);
        expect(g1.startDate, savingsGoal1.startDate);
        expect(g1.status, savingsGoal1.status);
        expect(g1.iconName, savingsGoal1.iconName);
        expect(g1.colorHex, savingsGoal1.colorHex);
        expect(g1.note, savingsGoal1.note);
        expect(g1.createdAt, savingsGoal1.createdAt);
        expect(g1.updatedAt, savingsGoal1.updatedAt);

        final g2 = restoredGoals.firstWhere((g) => g.id == 'goal-vacation');
        expect(g2.name, savingsGoal2.name);
        expect(g2.targetAmount, savingsGoal2.targetAmount);
        expect(g2.currentAmount, savingsGoal2.currentAmount);
        expect(g2.deadline, isNull);
        expect(g2.budgetId, isNull);
        expect(g2.autoDeduct, false);
        expect(g2.autoDeductAmount, isNull);
        expect(g2.lastAutoDeductedMonth, isNull);
        expect(g2.categoryId, isNull);
        expect(g2.targetDate, isNull);
        expect(g2.startDate, savingsGoal2.startDate);
        expect(g2.status, savingsGoal2.status);
        expect(g2.iconName, savingsGoal2.iconName);
        expect(g2.colorHex, savingsGoal2.colorHex);
        expect(g2.note, isNull);
        expect(g2.createdAt, savingsGoal2.createdAt);
        expect(g2.updatedAt, savingsGoal2.updatedAt);
      } finally {
        await freshDb.close();
      }
    });

    test('exportData and importData roundtrips across all 7 database tables', () async {
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

      const savingsGoal = SavingsGoal(
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
      await db.into(db.savingsGoalsTable).insert(savingsGoal);

      const transaction = Transaction(
        id: 'txn-1',
        amount: 15000,
        type: 'expense',
        categoryId: 'cat-1',
        date: 1704067200000,
        note: 'Lunch on card',
        merchantName: 'Supermarket',
        merchantId: 'merch-1',
        isRecurring: false,
        recurringId: null,
        isAutoCaptured: false,
        sourceApp: 'sms:hdfc',
        paymentMethod: 'debit_card',
        cardLast4: '4521',
        createdAt: 1000,
        updatedAt: 1000,
      );
      await db.into(db.transactionsTable).insert(transaction);

      const setting = AppSetting(
        key: 'currency',
        value: 'INR',
      );
      await db.into(db.appSettingsTable).insert(setting);

      // Export data (v2)
      final encryptedData = await backupEngine.exportData(passphrase);
      expect(encryptedData, isNotEmpty);

      // Restore into a completely fresh database instance
      final freshDb = AppDatabase(NativeDatabase.memory());
      final freshBackupEngine = BackupEngine(freshDb);

      try {
        await freshBackupEngine.importData(encryptedData, passphrase);

        // Verify all 7 tables restored
        final cats = await freshDb.select(freshDb.categoriesTable).get();
        expect(cats.length, 1);
        expect(cats.first.name, 'Food');

        final merchants = await freshDb.select(freshDb.merchantsTable).get();
        expect(merchants.length, 1);
        expect(merchants.first.name, 'Supermarket');

        final budgets = await freshDb.select(freshDb.budgetsTable).get();
        expect(budgets.length, 1);
        expect(budgets.first.name, 'Monthly Budget');

        final recs = await freshDb.select(freshDb.recurringTransactionsTable).get();
        expect(recs.length, 1);
        expect(recs.first.title, 'Netflix');

        final goals = await freshDb.select(freshDb.savingsGoalsTable).get();
        expect(goals.length, 1);
        expect(goals.first.name, 'Emergency Fund');

        final txns = await freshDb.select(freshDb.transactionsTable).get();
        expect(txns.length, 1);
        expect(txns.first.id, 'txn-1');
        expect(txns.first.paymentMethod, 'debit_card');

        final settings = await freshDb.select(freshDb.appSettingsTable).get();
        expect(settings.length, 1);
        expect(settings.first.key, 'currency');
      } finally {
        await freshDb.close();
      }
    });
  });

  group('BackupEngine - Integrity Verification & Restore Safety', () {
    test('tampered ciphertext fails HMAC verification and leaves database untouched', () async {
      const initialCat = Category(
        id: 'cat-orig',
        name: 'Original Category',
        icon: 'orig_icon',
        color: '#FFFFFF',
        isDefault: true,
        sortOrder: 1,
        createdAt: 1000,
        updatedAt: 1000,
      );
      await db.into(db.categoriesTable).insert(initialCat);

      final validExport = await backupEngine.exportData(passphrase);
      final parts = validExport.split(':');

      // Tamper ciphertext byte
      final cipherBytes = base64.decode(parts[3]);
      cipherBytes[0] ^= 0xFF;
      final tamperedCipherB64 = base64.encode(cipherBytes);
      final tamperedExport = '${parts[0]}:${parts[1]}:${parts[2]}:$tamperedCipherB64:${parts[4]}';

      expect(
        () => backupEngine.importData(tamperedExport, passphrase),
        throwsA(isA<CryptographyException>()),
      );

      final existingCats = await db.select(db.categoriesTable).get();
      expect(existingCats.length, 1);
      expect(existingCats.first.id, 'cat-orig');
    });

    test('wrong passphrase fails decryption and leaves database untouched', () async {
      const initialCat = Category(
        id: 'cat-orig',
        name: 'Original Category',
        icon: 'orig_icon',
        color: '#FFFFFF',
        isDefault: true,
        sortOrder: 1,
        createdAt: 1000,
        updatedAt: 1000,
      );
      await db.into(db.categoriesTable).insert(initialCat);

      final validExport = await backupEngine.exportData(passphrase);

      expect(
        () => backupEngine.importData(validExport, 'wrong_passphrase_456'),
        throwsA(isA<CryptographyException>()),
      );

      final existingCats = await db.select(db.categoriesTable).get();
      expect(existingCats.length, 1);
      expect(existingCats.first.id, 'cat-orig');
    });

    test('malformed or corrupt JSON payload rolls back and preserves existing data', () async {
      const initialCat = Category(
        id: 'cat-orig',
        name: 'Original Category',
        icon: 'orig_icon',
        color: '#FFFFFF',
        isDefault: true,
        sortOrder: 1,
        createdAt: 1000,
        updatedAt: 1000,
      );
      await db.into(db.categoriesTable).insert(initialCat);

      final invalidJsonEncrypted = EncryptionService.encryptWithPassphrase('NOT VALID JSON {{{', passphrase);

      expect(
        () => backupEngine.importData(invalidJsonEncrypted, passphrase),
        throwsA(isA<ValidationException>()),
      );

      final existingCats = await db.select(db.categoriesTable).get();
      expect(existingCats.length, 1);
      expect(existingCats.first.id, 'cat-orig');
    });
  });

  group('BackupEngine - Backward Compatibility with Legacy v1 Backups', () {
    test('successfully decrypts and restores legacy v1 backup without savings_goals gracefully', () async {
      final legacyPayload = {
        'formatVersion': 1,
        'appVersion': '1.0.0',
        'exportedAt': 1735689600000,
        'dbSchemaVersion': 1,
        'data': {
          // savingsGoals omitted entirely in legacy v1
          'categories': [
            {
              'id': 'cat-legacy',
              'name': 'Legacy Category',
              'icon': 'archive',
              'color': '#112233',
              'isDefault': false,
              'sortOrder': 0,
              'createdAt': 1000,
              'updatedAt': 1000,
            }
          ],
          'transactions': [
            {
              'id': 'txn-legacy',
              'amount': 25000,
              'type': 'expense',
              'categoryId': 'cat-legacy',
              'date': 1735689600000,
              'note': 'Old transaction',
              'merchantName': null,
              'merchantId': null,
              'isRecurring': false,
              'recurringId': null,
              'isAutoCaptured': false,
              'sourceApp': 'manual',
              'paymentMethod': 'cash',
              'cardLast4': null,
              'createdAt': 1000,
              'updatedAt': 1000,
            }
          ]
        }
      };

      // Construct legacy v1 single-round SHA-256 encrypted payload
      final bytes = utf8.encode(passphrase);
      final keyDigest = sha256.convert(bytes);
      final key = enc.Key(Uint8List.fromList(keyDigest.bytes));
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(jsonEncode(legacyPayload), iv: iv);
      final legacyEncryptedData = '${iv.base64}:${encrypted.base64}';

      // Import must succeed without error
      await backupEngine.importData(legacyEncryptedData, passphrase);

      final cats = await db.select(db.categoriesTable).get();
      expect(cats.length, 1);
      expect(cats.first.id, 'cat-legacy');

      final goals = await db.select(db.savingsGoalsTable).get();
      expect(goals, isEmpty);
    });
  });
}
