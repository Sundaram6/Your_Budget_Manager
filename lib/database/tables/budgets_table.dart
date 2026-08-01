import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('Budget')
class BudgetsTable extends Table {
  @override
  String get tableName => 'budgets';

  TextColumn get id => text()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)();
  RealColumn get amount => real()();
  TextColumn get periodType => text().withDefault(const Constant('monthly'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
