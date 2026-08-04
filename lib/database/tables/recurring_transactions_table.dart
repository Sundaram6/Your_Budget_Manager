import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('RecurringTransactionData')
class RecurringTransactionsTable extends Table {
  @override
  String get tableName => 'recurring_transactions';

  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)();
  TextColumn get type => text()(); // 'expense'|'income'
  TextColumn get frequency => text()(); // 'daily'|'weekly'|'biweekly'|'monthly'|'yearly'|'custom'
  IntColumn get intervalDays => integer().nullable()();
  TextColumn get startDate => text()(); // yyyy-MM-dd
  TextColumn get endDate => text().nullable()(); // yyyy-MM-dd
  TextColumn get nextDueDate => text()(); // yyyy-MM-dd
  TextColumn get lastGeneratedDate => text().nullable()(); // yyyy-MM-dd
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get autoConfirm => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()(); // ISO8601
  TextColumn get updatedAt => text()(); // ISO8601

  @override
  Set<Column> get primaryKey => {id};
}
