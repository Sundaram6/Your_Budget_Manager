import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/native.dart';
import '../../database/app_database.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/recurring/data/repositories/recurring_repository_impl.dart';
import '../../features/recurring/domain/repositories/recurring_repository.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase(NativeDatabase.memory());
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
