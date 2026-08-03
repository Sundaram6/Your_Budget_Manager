import '../../../../database/app_database.dart';

abstract class BudgetRepository {
  Stream<List<Budget>> watchAllBudgets();
  Future<List<Budget>> getBudgetsForMonth(int month, int year);
  Future<Budget?> getOverallBudget(int month, int year);
  Future<Budget?> getCategoryBudget(String categoryId, int month, int year);
  Future<void> insertBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<int> deleteBudget(Budget budget);
}
