import '../entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchAllCategories();
  Future<List<Category>> getCategories();
  Future<List<Category>> getDefaultCategories();
  Future<int> insertCategory(Category category);
  Future<bool> updateCategory(Category category);
  Future<int> deleteCategory(Category category);
}
