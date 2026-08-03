import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/savings_goals_table.dart';

part 'savings_goal_dao.g.dart';

@DriftAccessor(tables: [SavingsGoalsTable])
class SavingsGoalDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsGoalDaoMixin {
  SavingsGoalDao(super.db);

  /// Watch all active savings goals, ordered by creation date descending.
  Stream<List<SavingsGoal>> watchAll() => (select(savingsGoalsTable)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  /// Watch a single savings goal by ID.
  Stream<SavingsGoal?> watchById(String id) => (select(savingsGoalsTable)
        ..where((t) => t.id.equals(id)))
      .watchSingleOrNull();

  /// Watch goals linked to a specific budget ID.
  Stream<List<SavingsGoal>> watchGoalsForBudget(String budgetId) =>
      (select(savingsGoalsTable)..where((t) => t.budgetId.equals(budgetId))).watch();

  /// Get all goals once (non-reactive).
  Future<List<SavingsGoal>> getAll() => select(savingsGoalsTable).get();

  /// Get a single goal once.
  Future<SavingsGoal?> getById(String id) =>
      (select(savingsGoalsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get goals linked to a specific budget ID.
  Future<List<SavingsGoal>> getGoalsForBudget(String budgetId) =>
      (select(savingsGoalsTable)..where((t) => t.budgetId.equals(budgetId))).get();

  /// Get active goals with auto-deduct enabled for a specific budget ID or overall.
  Future<List<SavingsGoal>> getActiveAutoDeductGoalsForBudget(String? budgetId) {
    var query = select(savingsGoalsTable)
      ..where((t) => t.autoDeduct.equals(true) & t.status.equals('active'));
    if (budgetId != null) {
      query = query..where((t) => t.budgetId.equals(budgetId));
    }
    return query.get();
  }

  /// Insert a new savings goal.
  Future<void> insertGoal(SavingsGoalsTableCompanion goal) =>
      into(savingsGoalsTable).insert(goal);

  /// Update a savings goal.
  Future<bool> updateGoal(SavingsGoalsTableCompanion goal) =>
      update(savingsGoalsTable).replace(goal);

  /// Add deposit amount in paise to a goal's currentAmount.
  Future<void> addDepositPaise(String id, int amountPaise) async {
    final goal = await getById(id);
    if (goal == null) return;
    final newAmount = goal.currentAmount + amountPaise;
    final isCompleted = newAmount >= goal.targetAmount;
    await (update(savingsGoalsTable)..where((t) => t.id.equals(id))).write(
      SavingsGoalsTableCompanion(
        currentAmount: Value(newAmount),
        status: isCompleted ? const Value('completed') : Value(goal.status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Record auto-deduction executed for current month.
  Future<void> recordAutoDeduction(String id, String monthKey, int amountPaise) async {
    final goal = await getById(id);
    if (goal == null) return;
    final newAmount = goal.currentAmount + amountPaise;
    final isCompleted = newAmount >= goal.targetAmount;
    await (update(savingsGoalsTable)..where((t) => t.id.equals(id))).write(
      SavingsGoalsTableCompanion(
        currentAmount: Value(newAmount),
        lastAutoDeductedMonth: Value(monthKey),
        status: isCompleted ? const Value('completed') : Value(goal.status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Delete a savings goal.
  Future<int> deleteGoal(String id) =>
      (delete(savingsGoalsTable)..where((t) => t.id.equals(id))).go();
}
