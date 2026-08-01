import '../entities/budget.dart';

abstract class BudgetRepository {
  Stream<List<Budget>> watchAllBudgets();
  Stream<List<Budget>> watchActiveBudgets();
  Future<int> insertBudget(Budget budget);
  Future<bool> updateBudget(Budget budget);
  Future<int> deleteBudget(Budget budget);
}
