import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('SavingsGoal')
class SavingsGoalsTable extends Table {
  @override
  String get tableName => 'savings_goals';

  TextColumn get id => text()();
  TextColumn get name => text()(); // e.g. "Emergency Fund", "iPhone 16"
  RealColumn get targetAmount => real()(); // target ₹ amount
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))(); // deposited so far
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
