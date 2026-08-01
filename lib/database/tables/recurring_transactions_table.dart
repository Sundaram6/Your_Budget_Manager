import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('RecurringTransaction')
class RecurringTransactionsTable extends Table {
  @override
  String get tableName => 'recurring_transactions';

  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)();
  TextColumn get frequency => text()();
  IntColumn get startDate => integer()();
  IntColumn get endDate => integer().nullable()();
  IntColumn get nextDueDate => integer()();
  IntColumn get lastProcessedDate => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
