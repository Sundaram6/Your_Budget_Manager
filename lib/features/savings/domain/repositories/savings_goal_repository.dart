import '../../../../database/app_database.dart';

abstract class SavingsGoalRepository {
  Stream<List<SavingsGoal>> watchAllGoals();
  Stream<SavingsGoal?> watchGoalById(String id);
  Stream<List<SavingsGoal>> watchGoalsForBudget(String budgetId);

  Future<List<SavingsGoal>> getAllGoals();
  Future<SavingsGoal?> getGoalById(String id);
  Future<List<SavingsGoal>> getGoalsForBudget(String budgetId);
  Future<List<SavingsGoal>> getActiveAutoDeductGoalsForBudget(String? budgetId);

  Future<void> createGoal(SavingsGoalsTableCompanion goal);
  Future<bool> updateGoal(SavingsGoalsTableCompanion goal);
  Future<void> addDepositPaise(String id, int amountPaise);
  Future<void> recordAutoDeduction(String id, String monthKey, int amountPaise);
  Future<int> deleteGoal(String id);
}
