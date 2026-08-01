import 'package:drift/drift.dart';
import 'categories_table.dart';
import 'merchants_table.dart';
import 'recurring_transactions_table.dart';

@DataClassName('Transaction')
class TransactionsTable extends Table {
  @override
  String get tableName => 'transactions';

  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()();
  TextColumn get categoryId => text().references(CategoriesTable, #id)();
  IntColumn get date => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get merchantName => text().nullable()();
  TextColumn get merchantId => text().nullable().references(MerchantsTable, #id)();
  TextColumn get recurringId => text().nullable().references(RecurringTransactionsTable, #id)();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
