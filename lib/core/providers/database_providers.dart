import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/security/database_key_service.dart';
import '../../database/app_database.dart';
import '../../database/daos/savings_goal_dao.dart';
import '../../database/database_helper.dart';
import '../../database/encryption_migration.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/savings/data/repositories/savings_goal_repository_impl.dart';
import '../../features/savings/domain/repositories/savings_goal_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../repositories/recurring_repository.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(
    LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final plainFile = File(p.join(dbFolder.path, 'ybm_data.sqlite'));
      final cryptFile = File(p.join(dbFolder.path, 'ybm_data_enc.sqlite'));

      final keyService = DatabaseKeyService();
      final key = await keyService.getOrCreateDbKey();

      await EncryptionMigration.encryptExistingDatabaseIfNeeded(
        plaintextFile: plainFile,
        encryptedFile: cryptFile,
        key: key,
      );

      final escapedKey = EncryptionMigration.escapeSqlString(key);

      return NativeDatabase.createInBackground(
        cryptFile,
        setup: (rawDb) {
          EncryptionMigration.verifyCipherSupport(
            rawDb,
            context: 'foreground appDatabaseProvider',
          );
          rawDb.execute("PRAGMA key = '$escapedKey';");
        },
      );
    }),
  );
  DatabaseHelper.instance.setDatabase(db);
  ref.onDispose(() {
    db.close();
  });
  return db;
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryRepositoryImpl(db.categoryDao);
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepositoryImpl(db.transactionDao);
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetRepositoryImpl(db.budgetDao);
}

@Riverpod(keepAlive: true)
RecurringRepository recurringRepository(Ref ref) {
  ref.watch(appDatabaseProvider);
  return RecurringRepository.instance;
}

@Riverpod(keepAlive: true)
SavingsGoalDao savingsGoalDao(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.savingsGoalDao;
}

@Riverpod(keepAlive: true)
SavingsGoalRepository savingsGoalRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return SavingsGoalRepositoryImpl(db.savingsGoalDao);
}

