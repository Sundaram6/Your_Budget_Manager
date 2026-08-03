import 'package:drift/drift.dart';
import 'budgets_table.dart';
import 'categories_table.dart';

@DataClassName('SavingsGoal')
class SavingsGoalsTable extends Table {
  @override
  String get tableName => 'savings_goals';

  TextColumn get id => text()();
  TextColumn get name => text()(); // e.g. "Emergency Fund", "iPhone 16"
  IntColumn get targetAmount => integer()(); // target amount in paise
  IntColumn get currentAmount => integer().withDefault(const Constant(0))(); // deposited so far in paise
  IntColumn get deadline => integer().nullable()(); // unix timestamp / epoch millis, NULL = no deadline
  TextColumn get budgetId => text().nullable().references(BudgetsTable, #id)(); // links to budgets_table.id
  BoolColumn get autoDeduct => boolean().withDefault(const Constant(false))();
  IntColumn get autoDeductAmount => integer().nullable()(); // paise per month
  TextColumn get lastAutoDeductedMonth => text().nullable()(); // e.g. '2026-08' to prevent duplicate auto-deductions

  TextColumn get categoryId => text().nullable().references(CategoriesTable, #id)();
  IntColumn get targetDate => integer().nullable()(); // unix timestamp, NULL = no deadline
  IntColumn get startDate => integer()(); // unix timestamp
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active'|'completed'|'paused'
  TextColumn get iconName => text().withDefault(const Constant('savings'))(); // icon identifier
  TextColumn get colorHex => text().withDefault(const Constant('#FFD700'))(); // hex color
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
