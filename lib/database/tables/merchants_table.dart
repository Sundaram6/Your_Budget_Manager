import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('Merchant')
class MerchantsTable extends Table {
  @override
  String get tableName => 'merchants';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get defaultCategoryId => text().nullable().references(CategoriesTable, #id)();
  TextColumn get matchPattern => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
