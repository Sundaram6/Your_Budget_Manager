import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/app_database.dart';
import '../../database/daos/savings_goal_dao.dart';
import '../../database/database_helper.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/recurring/data/repositories/recurring_repository_impl.dart';
import '../../features/recurring/domain/repositories/recurring_repository.dart';
import '../../features/savings/data/repositories/savings_goal_repository_impl.dart';
import '../../features/savings/domain/repositories/savings_goal_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase(
    LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'ybm_data.sqlite'));
      return NativeDatabase.createInBackground(file);
    }),
  );
  DatabaseHelper.instance.setDatabase(db);
  ref.onDispose(() {
    db.close();
  });
  return db;
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryRepositoryImpl(db.categoryDao);
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepositoryImpl(db.transactionDao);
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(BudgetRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetRepositoryImpl(db.budgetDao);
}

@Riverpod(keepAlive: true)
RecurringRepository recurringRepository(RecurringRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return RecurringRepositoryImpl(db.recurringTransactionDao);
}

@Riverpod(keepAlive: true)
SavingsGoalDao savingsGoalDao(SavingsGoalDaoRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.savingsGoalDao;
}

@Riverpod(keepAlive: true)
SavingsGoalRepository savingsGoalRepository(SavingsGoalRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return SavingsGoalRepositoryImpl(db.savingsGoalDao);
}
