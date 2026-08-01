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
}
