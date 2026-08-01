import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';

void main() {
  late AppDatabase database;
  late CategoryDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.categoryDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and retrieve categories', () async {
    await dao.insertCategory(
      CategoriesTableCompanion.insert(
        id: '1',
        name: 'Food',
        icon: 'fastfood',
        color: 'red',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final categories = await dao.getCategories();
    expect(categories.length, 1);
    expect(categories.first.name, 'Food');
  });

  test('watch categories streams updates', () async {
    final stream = dao.watchAllCategories();
    
    // First emission should be empty
    expect(await stream.first, isEmpty);

    await dao.insertCategory(
      CategoriesTableCompanion.insert(
        id: '1',
        name: 'Food',
        icon: 'fastfood',
        color: 'red',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    // Wait for the next emission
    final categories = await stream.firstWhere((list) => list.isNotEmpty);
    expect(categories.length, 1);
    expect(categories.first.name, 'Food');
  });
}
