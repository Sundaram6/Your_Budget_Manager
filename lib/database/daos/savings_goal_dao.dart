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

  /// Get all goals once (non-reactive).
  Future<List<SavingsGoal>> getAll() => select(savingsGoalsTable).get();

  /// Insert a new savings goal.
  Future<void> insertGoal(SavingsGoalsTableCompanion goal) =>
      into(savingsGoalsTable).insert(goal);

  /// Update a savings goal.
  Future<bool> updateGoal(SavingsGoalsTableCompanion goal) =>
      update(savingsGoalsTable).replace(goal);

  /// Add deposit amount to a goal's currentAmount.
  Future<void> addDeposit(String id, double amount) async {
    final goal = await (select(savingsGoalsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (goal == null) return;
    final newAmount = goal.currentAmount + amount;
    final isCompleted = newAmount >= goal.targetAmount;
    await (update(savingsGoalsTable)..where((t) => t.id.equals(id))).write(
      SavingsGoalsTableCompanion(
        currentAmount: Value(newAmount),
        status: isCompleted ? const Value('completed') : Value(goal.status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Delete a savings goal.
  Future<int> deleteGoal(String id) =>
      (delete(savingsGoalsTable)..where((t) => t.id.equals(id))).go();
}
