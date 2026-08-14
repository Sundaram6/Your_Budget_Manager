import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/errors/app_exception.dart';
import '../../database/app_database.dart';
import '../../database/daos/savings_goal_dao.dart';
import '../../features/savings/domain/repositories/savings_goal_repository.dart';

class SavingsEngine {
  final SavingsGoalDao _dao;
  final SavingsGoalRepository? _repo;

  SavingsEngine(this._dao, [this._repo]);

  static const _uuid = Uuid();

  /// Watch all savings goals as a reactive stream.
  Stream<List<SavingsGoal>> watchGoals() => _dao.watchAll();

  /// Watch a single goal by ID.
  Stream<SavingsGoal?> watchGoal(String id) => _dao.watchById(id);

  /// Watch goals linked to a specific budget.
  Stream<List<SavingsGoal>> watchGoalsForBudget(String budgetId) =>
      _dao.watchGoalsForBudget(budgetId);

  /// Create a new savings goal (targetAmount in paise).
  Future<void> createGoal({
    required String name,
    required int targetAmountPaise,
    DateTime? deadline,
    String? linkedBudgetId,
    bool autoDeduct = false,
    int? autoDeductAmountPaise,
    String? categoryId,
    String iconName = 'savings',
    String colorHex = '#FFD700',
    String? note,
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Goal name must not be empty');
    }
    if (targetAmountPaise <= 0) {
      throw const ValidationException('Target amount must be positive');
    }

    final now = DateTime.now();
    final id = _uuid.v4();

    final companion = SavingsGoalsTableCompanion.insert(
      id: id,
      name: name,
      targetAmount: targetAmountPaise,
      currentAmount: const Value(0),
      deadline: Value(deadline?.millisecondsSinceEpoch),
      budgetId: Value(linkedBudgetId),
      autoDeduct: Value(autoDeduct),
      autoDeductAmount: Value(autoDeductAmountPaise),
      categoryId: Value(categoryId),
      targetDate: Value(deadline?.millisecondsSinceEpoch),
      startDate: now.millisecondsSinceEpoch,
      iconName: Value(iconName),
      colorHex: Value(colorHex),
      note: Value(note),
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );

    if (_repo != null) {
      await _repo.createGoal(companion);
    } else {
      await _dao.insertGoal(companion);
    }
  }

  /// Update an existing savings goal (targetAmount in paise).
  Future<bool> updateGoal({
    required String id,
    required String name,
    required int targetAmountPaise,
    DateTime? deadline,
    String? linkedBudgetId,
    bool autoDeduct = false,
    int? autoDeductAmountPaise,
    String? categoryId,
    String? iconName,
    String? colorHex,
    String? note,
  }) async {
    if (id.trim().isEmpty) {
      throw const ValidationException('Goal ID must not be empty');
    }
    if (name.trim().isEmpty) {
      throw const ValidationException('Goal name must not be empty');
    }
    if (targetAmountPaise <= 0) {
      throw const ValidationException('Target amount must be positive');
    }

    final companion = SavingsGoalsTableCompanion(
      id: Value(id),
      name: Value(name),
      targetAmount: Value(targetAmountPaise),
      deadline: Value(deadline?.millisecondsSinceEpoch),
      budgetId: Value(linkedBudgetId),
      autoDeduct: Value(autoDeduct),
      autoDeductAmount: Value(autoDeductAmountPaise),
      categoryId: Value(categoryId),
      targetDate: Value(deadline?.millisecondsSinceEpoch),
      iconName: iconName != null ? Value(iconName) : const Value.absent(),
      colorHex: colorHex != null ? Value(colorHex) : const Value.absent(),
      note: Value(note),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );

    if (_repo != null) {
      return await _repo.updateGoal(companion);
    } else {
      return await _dao.updateGoal(companion);
    }
  }

  /// Contribute/deposit an amount in paise to a goal.
  Future<void> contributeToGoal(String goalId, int amountPaise) async {
    if (amountPaise <= 0) {
      throw const ValidationException('Contribution amount must be positive');
    }
    if (_repo != null) {
      await _repo.addDepositPaise(goalId, amountPaise);
    } else {
      await _dao.addDepositPaise(goalId, amountPaise);
    }
  }

  /// Get goals linked to a specific budget ID.
  Future<List<SavingsGoal>> getGoalsForBudget(String budgetId) async {
    if (_repo != null) {
      return _repo.getGoalsForBudget(budgetId);
    }
    return _dao.getGoalsForBudget(budgetId);
  }

  /// Get total savings across all active goals in paise.
  Future<int> getTotalSavings() async {
    final goals = _repo != null ? await _repo.getAllGoals() : await _dao.getAll();
    return goals.fold<int>(0, (sum, g) => sum + g.currentAmount);
  }

  /// Calculate recommended monthly savings based on the 50/30/20 rule.
  /// Inputs & outputs are in integer paise.
  ({int needs, int wants, int savings}) calculate50_30_20(int monthlyIncomePaise) {
    if (monthlyIncomePaise <= 0) {
      return (needs: 0, wants: 0, savings: 0);
    }
    final needs = (monthlyIncomePaise * 0.5).round();
    final wants = (monthlyIncomePaise * 0.3).round();
    final savings = (monthlyIncomePaise * 0.2).round();
    return (needs: needs, wants: wants, savings: savings);
  }

  /// Execute auto-deduction for all goals linked to a budget where autoDeduct == true.
  /// Strictly guarded by month key (e.g., '2026-08') so auto-deduction occurs ONLY ONCE per month.
  Future<void> executeAutoDeductions(String budgetId) async {
    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);

    final goals = _repo != null
        ? await _repo.getActiveAutoDeductGoalsForBudget(budgetId)
        : await _dao.getActiveAutoDeductGoalsForBudget(budgetId);

    for (final goal in goals) {
      if (goal.autoDeductAmount == null || goal.autoDeductAmount! <= 0) continue;

      // Skip if auto-deduction already executed this month
      if (goal.lastAutoDeductedMonth == monthKey) continue;

      if (_repo != null) {
        await _repo.recordAutoDeduction(goal.id, monthKey, goal.autoDeductAmount!);
      } else {
        await _dao.recordAutoDeduction(goal.id, monthKey, goal.autoDeductAmount!);
      }
    }
  }

  /// Delete a goal.
  Future<void> deleteGoal(String goalId) async {
    if (_repo != null) {
      await _repo.deleteGoal(goalId);
    } else {
      await _dao.deleteGoal(goalId);
    }
  }
}
