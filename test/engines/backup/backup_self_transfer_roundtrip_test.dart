import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';

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

    final catDao1 = CategoryDao(db1);
    final catRepo1 = CategoryRepositoryImpl(catDao1);
    await CategoryEngine(catRepo1).seedDefaults();
  });

  tearDown(() async {
    await db1.close();
    await db2.close();
  });

  test('Backup and restore preserves transfer_pair_id and self-transfer links', () async {
    const pairId = 'tf_backup_roundtrip_123';
    final now = DateTime(2026, 8, 16, 12, 0).millisecondsSinceEpoch;

    // Insert linked pair into db1
    await db1.into(db1.transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_debit_pair',
        amount: 80000,
        type: 'expense',
        categoryId: CategoryEngine.catFood,
        date: now,
        transferPairId: const Value(pairId),
        accountLast4: const Value('1122'),
        transactionRef: const Value('REF_BACKUP_1'),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await db1.into(db1.transactionsTable).insert(
      TransactionsTableCompanion.insert(
        id: 'tx_credit_pair',
        amount: 80000,
        type: 'income',
        categoryId: CategoryEngine.catIncome,
        date: now,
        transferPairId: const Value(pairId),
        accountLast4: const Value('3344'),
        transactionRef: const Value('REF_BACKUP_1'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Export encrypted backup
    const passphrase = 'SuperSecretBackupPassword123!';
    final encryptedBackup = await backupEngine1.exportData(passphrase);
    expect(encryptedBackup, isNotEmpty);

    // Import into db2
    await backupEngine2.importData(encryptedBackup, passphrase);

    // Verify records in db2
    final restoredTxs = await db2.select(db2.transactionsTable).get();
    expect(restoredTxs.length, equals(2));

    final debit = restoredTxs.firstWhere((t) => t.id == 'tx_debit_pair');
    final credit = restoredTxs.firstWhere((t) => t.id == 'tx_credit_pair');

    expect(debit.transferPairId, equals(pairId));
    expect(credit.transferPairId, equals(pairId));
    expect(debit.accountLast4, equals('1122'));
    expect(credit.accountLast4, equals('3344'));
    expect(debit.transactionRef, equals('REF_BACKUP_1'));
  });
}
