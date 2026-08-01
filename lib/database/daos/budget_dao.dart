import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [BudgetsTable])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Stream<List<Budget>> watchAllBudgets() => select(budgetsTable).watch();

  Stream<List<Budget>> watchActiveBudgets() {
    return (select(budgetsTable)..where((t) => t.isActive.equals(true))).watch();
  }

  Future<int> insertBudget(Insertable<Budget> budget) => into(budgetsTable).insert(budget);

  Future<bool> updateBudget(Insertable<Budget> budget) => update(budgetsTable).replace(budget);

  Future<int> deleteBudget(Insertable<Budget> budget) => delete(budgetsTable).delete(budget);
}
