// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_dao.dart';

// ignore_for_file: type=lint
mixin _$SavingsGoalDaoMixin on DatabaseAccessor<AppDatabase> {
  $BudgetsTableTable get budgetsTable => attachedDatabase.budgetsTable;
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $SavingsGoalsTableTable get savingsGoalsTable =>
      attachedDatabase.savingsGoalsTable;
  SavingsGoalDaoManager get managers => SavingsGoalDaoManager(this);
}

class SavingsGoalDaoManager {
  final _$SavingsGoalDaoMixin _db;
  SavingsGoalDaoManager(this._db);
  $$BudgetsTableTableTableManager get budgetsTable =>
      $$BudgetsTableTableTableManager(_db.attachedDatabase, _db.budgetsTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$SavingsGoalsTableTableTableManager get savingsGoalsTable =>
      $$SavingsGoalsTableTableTableManager(
        _db.attachedDatabase,
        _db.savingsGoalsTable,
      );
}
