import 'package:drift/drift.dart';

@DataClassName('Budget')
class BudgetsTable extends Table {
  @override
  String get tableName => 'budgets';

  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant('Monthly Budget'))();
  TextColumn get categoryId => text().nullable()(); // null = overall monthly budget
  IntColumn get amount => integer()(); // Amount stored in paise (₹20,000 = 2000000)
  IntColumn get month => integer()(); // 1-12
  IntColumn get year => integer()(); // 2026
  IntColumn get createdAt => integer()();
  TextColumn get type => text().withDefault(const Constant('monthly'))();

  @override
  Set<Column> get primaryKey => {id};
}
