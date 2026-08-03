import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [BudgetsTable])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Stream<List<Budget>> watchAllBudgets() => select(budgetsTable).watch();

  Future<List<Budget>> getBudgetsForMonth(int month, int year) {
    return (select(budgetsTable)
          ..where((t) => t.month.equals(month) & t.year.equals(year)))
        .get();
  }

  Future<Budget?> getOverallBudget(int month, int year) {
    return (select(budgetsTable)
          ..where((t) => t.month.equals(month) & t.year.equals(year) & t.categoryId.isNull()))
        .getSingleOrNull();
  }

  Future<Budget?> getCategoryBudget(String categoryId, int month, int year) {
    return (select(budgetsTable)
          ..where((t) => t.month.equals(month) & t.year.equals(year) & t.categoryId.equals(categoryId)))
        .getSingleOrNull();
  }

  Future<int> insertBudget(Insertable<Budget> budget) => into(budgetsTable).insert(budget);

  Future<bool> updateBudget(Insertable<Budget> budget) => update(budgetsTable).replace(budget);

  Future<int> deleteBudget(Insertable<Budget> budget) => delete(budgetsTable).delete(budget);
}
