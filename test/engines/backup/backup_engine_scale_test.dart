import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db1;
  late AppDatabase db2;
  late BackupEngine backupEngine1;
  late BackupEngine backupEngine2;

  setUp(() async {
    db1 = AppDatabase(NativeDatabase.memory());
    db2 = AppDatabase(NativeDatabase.memory());
    backupEngine1 = BackupEngine(db1);
    backupEngine2 = BackupEngine(db2);
  });

  tearDown(() async {
    await db1.close();
    await db2.close();
  });

  test('BackupEngine scale test: exports and imports 500+ transactions with self-transfer pairs and full metadata', () async {
    const passphrase = 'test_scale_passphrase_789';

    // 1. Seed database with categories
    await db1.into(db1.categoriesTable).insert(
      CategoriesTableCompanion.insert(
        id: 'cat_food',
        name: 'Food & Dining',
        icon: 'restaurant',
        color: '#FF5722',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );
    await db1.into(db1.categoriesTable).insert(
      CategoriesTableCompanion.insert(
        id: 'cat_transfer',
        name: 'Transfer',
        icon: 'swap_horiz',
        color: '#FFC64B',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    // 2. Seed 500 transactions (250 normal + 125 transfer pairs = 250 rows)
    final now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 250; i++) {
      await db1.into(db1.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          id: 'tx_norm_$i',
          amount: 1000 + i * 50,
          type: i % 3 == 0 ? 'income' : 'expense',
          categoryId: 'cat_food',
          date: now - i * 60000,
          createdAt: now - i * 60000,
          updatedAt: now - i * 60000,
          note: Value('Normal expense or income note #$i'),
          sourceApp: const Value('sms:hdfc'),
          paymentMethod: const Value('upi'),
          accountLast4: const Value('1234'),
          transactionRef: Value('REF_$i'),
        ),
      );
    }

    // 125 self-transfer pairs (250 rows)
    for (int i = 0; i < 125; i++) {
      final pairId = 'tf_pair_$i';
      // Debit side
      await db1.into(db1.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          id: 'tx_tf_debit_$i',
          amount: 50000 + i * 100,
          type: 'expense',
          categoryId: 'cat_transfer',
          date: now - (i * 120000),
          createdAt: now - (i * 120000),
          updatedAt: now - (i * 120000),
          transferPairId: Value(pairId),
          sourceApp: const Value('sms:hdfc'),
          paymentMethod: const Value('netbanking'),
          accountLast4: const Value('1111'),
          transactionRef: Value('UTR_$i'),
        ),
      );

      // Credit side
      await db1.into(db1.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          id: 'tx_tf_credit_$i',
          amount: 50000 + i * 100,
          type: 'income',
          categoryId: 'cat_transfer',
          date: now - (i * 120000) + 15000,
          createdAt: now - (i * 120000) + 15000,
          updatedAt: now - (i * 120000) + 15000,
          transferPairId: Value(pairId),
          sourceApp: const Value('sms:icici'),
          paymentMethod: const Value('netbanking'),
          accountLast4: const Value('2222'),
          transactionRef: Value('UTR_$i'),
        ),
      );
    }

    // Verify 500 total transactions in source DB
    final initialCount = await db1.select(db1.transactionsTable).get();
    expect(initialCount.length, 500);

    // 3. Export data (runs in background isolate via compute)
    final stopwatch = Stopwatch()..start();
    final encryptedData = await backupEngine1.exportData(passphrase);
    stopwatch.stop();

    expect(encryptedData, startsWith('v2:'));
    expect(encryptedData.length, greaterThan(1000));

    // 4. Import data into fresh db2 (runs in background isolate via compute)
    await backupEngine2.importData(encryptedData, passphrase);

    // 5. Verify restored rows
    final restoredCategories = await db2.select(db2.categoriesTable).get();
    expect(restoredCategories.length, 2);

    final restoredTransactions = await db2.select(db2.transactionsTable).get();
    expect(restoredTransactions.length, 500);

    // Verify transfer pair integrity across round-trip
    final restoredTransfers = restoredTransactions.where((t) => t.transferPairId != null).toList();
    expect(restoredTransfers.length, 250);

    final debit0 = restoredTransactions.firstWhere((t) => t.id == 'tx_tf_debit_0');
    final credit0 = restoredTransactions.firstWhere((t) => t.id == 'tx_tf_credit_0');
    expect(debit0.transferPairId, 'tf_pair_0');
    expect(credit0.transferPairId, 'tf_pair_0');
    expect(debit0.amount, 50000);
    expect(credit0.amount, 50000);
    expect(debit0.type, 'expense');
    expect(credit0.type, 'income');
    expect(debit0.accountLast4, '1111');
    expect(credit0.accountLast4, '2222');
  });
}
