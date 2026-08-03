import '../../../../database/app_database.dart';
import '../../../../database/daos/savings_goal_dao.dart';
import '../../domain/repositories/savings_goal_repository.dart';

class SavingsGoalRepositoryImpl implements SavingsGoalRepository {
  final SavingsGoalDao _dao;

  SavingsGoalRepositoryImpl(this._dao);

  @override
  Stream<List<SavingsGoal>> watchAllGoals() => _dao.watchAll();

  @override
  Stream<SavingsGoal?> watchGoalById(String id) => _dao.watchById(id);

  @override
  Stream<List<SavingsGoal>> watchGoalsForBudget(String budgetId) => _dao.watchGoalsForBudget(budgetId);

  @override
  Future<List<SavingsGoal>> getAllGoals() => _dao.getAll();

  @override
  Future<SavingsGoal?> getGoalById(String id) => _dao.getById(id);

  @override
  Future<List<SavingsGoal>> getGoalsForBudget(String budgetId) => _dao.getGoalsForBudget(budgetId);

  @override
  Future<List<SavingsGoal>> getActiveAutoDeductGoalsForBudget(String? budgetId) =>
      _dao.getActiveAutoDeductGoalsForBudget(budgetId);

  @override
  Future<void> createGoal(SavingsGoalsTableCompanion goal) => _dao.insertGoal(goal);

  @override
  Future<bool> updateGoal(SavingsGoalsTableCompanion goal) => _dao.updateGoal(goal);

  @override
  Future<void> addDepositPaise(String id, int amountPaise) => _dao.addDepositPaise(id, amountPaise);

  @override
  Future<void> recordAutoDeduction(String id, String monthKey, int amountPaise) =>
      _dao.recordAutoDeduction(id, monthKey, amountPaise);

  @override
  Future<int> deleteGoal(String id) => _dao.deleteGoal(id);
}
