import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchAllCategories() => select(categoriesTable).watch();

  Future<List<Category>> getCategories() => select(categoriesTable).get();

  Future<Category?> getCategoryById(String id) {
    return (select(categoriesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }


  Future<List<Category>> getDefaultCategories() {
    return (select(categoriesTable)..where((t) => t.isDefault.equals(true))).get();
  }

  Future<int> insertCategory(Insertable<Category> category) => into(categoriesTable).insert(category);

  Future<bool> updateCategory(Insertable<Category> category) => update(categoriesTable).replace(category);

  Future<int> deleteCategory(Insertable<Category> category) => delete(categoriesTable).delete(category);

  Future<void> migrateLegacyCategories(Map<String, String> nameToFixedIdMap) async {
    final fixedIds = {
      'cat_groceries',
      'cat_shopping',
      'cat_food',
      'cat_transport',
      'cat_utilities',
      'cat_entertainment',
      'cat_income',
      'cat_uncategorized',
    };

    await db.transaction(() async {
      final existing = await select(categoriesTable).get();
      for (final cat in existing) {
        // Migrate if it's an old default category with a dynamic UUID OR if its name maps to a fixed ID but its ID is different
        final isOldUuidDefault = cat.isDefault && !fixedIds.contains(cat.id);
        final isNameMapped = nameToFixedIdMap.containsKey(cat.name) && cat.id != nameToFixedIdMap[cat.name];

        if (isOldUuidDefault || isNameMapped) {
          final oldId = cat.id;
          final newId = nameToFixedIdMap[cat.name] ?? 'cat_uncategorized';

          // 1. Ensure target fixed category exists in categories table
          final fixedCat = await (select(categoriesTable)..where((t) => t.id.equals(newId))).getSingleOrNull();
          if (fixedCat == null) {
            await into(categoriesTable).insert(
              CategoriesTableCompanion.insert(
                id: newId,
                name: cat.name,
                icon: cat.icon,
                color: cat.color,
                isDefault: const Value(true),
                sortOrder: Value(cat.sortOrder),
                createdAt: cat.createdAt,
                updatedAt: cat.updatedAt,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }

          // 2. Remap foreign keys in all tables before deleting old category row
          await db.customUpdate(
            'UPDATE transactions SET category_id = ? WHERE category_id = ?',
            variables: [Variable.withString(newId), Variable.withString(oldId)],
          );
          await db.customUpdate(
            'UPDATE budgets SET category_id = ? WHERE category_id = ?',
            variables: [Variable.withString(newId), Variable.withString(oldId)],
          );
          await db.customUpdate(
            'UPDATE merchants SET default_category_id = ? WHERE default_category_id = ?',
            variables: [Variable.withString(newId), Variable.withString(oldId)],
          );

          // 3. Delete old UUID category row safely after FK remapping
          await (delete(categoriesTable)..where((t) => t.id.equals(oldId))).go();
        }
      }
    });
  }


}

