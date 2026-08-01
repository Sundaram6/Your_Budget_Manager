import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import '../../database/daos/savings_goal_dao.dart';
import 'models/savings_goal.dart';
import 'package:drift/drift.dart';

class SavingsEngine {
  SavingsEngine(this._dao);

  final SavingsGoalDao _dao;
  static const _uuid = Uuid();

  /// Watch all savings goals as a reactive stream.
  Stream<List<SavingsGoalModel>> watchGoals() =>
      _dao.watchAll().map((goals) => goals.map(_toModel).toList());

  /// Watch a single goal.
  Stream<SavingsGoalModel?> watchGoal(String id) =>
      _dao.watchById(id).map((g) => g != null ? _toModel(g) : null);

  /// Create a new savings goal.
  Future<void> createGoal({
    required String name,
    required double targetAmount,
    String? categoryId,
    DateTime? targetDate,
    String iconName = 'savings',
    String colorHex = '#FFD700',
    String? note,
  }) async {
    assert(name.isNotEmpty, 'Goal name must not be empty');
    assert(targetAmount > 0, 'Target amount must be positive');

    final now = DateTime.now();
    final id = _uuid.v4();

    await _dao.insertGoal(SavingsGoalsTableCompanion.insert(
      id: id,
      name: name,
      targetAmount: targetAmount,
      categoryId: Value(categoryId),
      targetDate: Value(targetDate?.millisecondsSinceEpoch),
      startDate: now.millisecondsSinceEpoch,
      iconName: Value(iconName),
      colorHex: Value(colorHex),
      note: Value(note),
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    ));
  }

  /// Add a deposit to an existing goal.
  Future<void> deposit(String goalId, double amount) async {
    assert(amount > 0, 'Deposit amount must be positive');
    await _dao.addDeposit(goalId, amount);
  }

  /// Pause a goal.
  Future<void> pauseGoal(String goalId) async {
    final now = DateTime.now();
    await _dao.updateGoal(SavingsGoalsTableCompanion(
      id: Value(goalId),
      status: const Value('paused'),
      updatedAt: Value(now.millisecondsSinceEpoch),
    ));
  }

  /// Resume a paused goal.
  Future<void> resumeGoal(String goalId) async {
    final now = DateTime.now();
    await _dao.updateGoal(SavingsGoalsTableCompanion(
      id: Value(goalId),
      status: const Value('active'),
      updatedAt: Value(now.millisecondsSinceEpoch),
    ));
  }

  /// Delete a goal permanently.
  Future<void> deleteGoal(String goalId) => _dao.deleteGoal(goalId);

  /// Get total amount saved across all active goals.
  Future<double> totalSaved() async {
    final goals = await _dao.getAll();
    return goals.fold<double>(0.0, (sum, g) => sum + g.currentAmount);
  }

  // ── private helpers ────────────────────────────────────────────────────────

  SavingsGoalModel _toModel(SavingsGoal g) => SavingsGoalModel(
        id: g.id,
        name: g.name,
        targetAmount: g.targetAmount,
        currentAmount: g.currentAmount,
        categoryId: g.categoryId,
        targetDate: g.targetDate != null
            ? DateTime.fromMillisecondsSinceEpoch(g.targetDate!)
            : null,
        startDate: DateTime.fromMillisecondsSinceEpoch(g.startDate),
        status: _parseStatus(g.status),
        iconName: g.iconName,
        colorHex: g.colorHex,
        note: g.note,
        createdAt: DateTime.fromMillisecondsSinceEpoch(g.createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(g.updatedAt),
      );

  SavingsGoalStatus _parseStatus(String s) => switch (s) {
        'completed' => SavingsGoalStatus.completed,
        'paused' => SavingsGoalStatus.paused,
        _ => SavingsGoalStatus.active,
      };
}
