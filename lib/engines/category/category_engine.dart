import 'package:uuid/uuid.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/categories/domain/repositories/category_repository.dart';

class CategoryEngine {
  final CategoryRepository _repository;
  final Uuid _uuid;

  CategoryEngine(this._repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  Future<void> seedDefaults() async {
    final existing = await _repository.getCategories();
    if (existing.isEmpty) {
      final now = DateTime.now();
      final defaults = [
        Category(
          id: _uuid.v4(),
          name: 'Groceries',
          icon: 'shopping_cart',
          color: int.parse('10B981', radix: 16) | 0xFF000000,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        Category(
          id: _uuid.v4(),
          name: 'Online Shopping',
          icon: 'shopping_bag',
          color: int.parse('8B5CF6', radix: 16) | 0xFF000000,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        Category(
          id: _uuid.v4(),
          name: 'Food Delivery',
          icon: 'restaurant',
          color: int.parse('F59E0B', radix: 16) | 0xFF000000,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        Category(
          id: _uuid.v4(),
          name: 'Transport',
          icon: 'directions_car',
          color: int.parse('3B82F6', radix: 16) | 0xFF000000,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        Category(
          id: _uuid.v4(),
          name: 'Utilities',
          icon: 'bolt',
          color: int.parse('6366F1', radix: 16) | 0xFF000000,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
        Category(
          id: _uuid.v4(),
          name: 'Entertainment',
          icon: 'movie',
          color: int.parse('EC4899', radix: 16) | 0xFF000000,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      for (final category in defaults) {
        await _repository.insertCategory(category);
      }
    }
  }

  Future<List<Category>> getAll() => _repository.getCategories();

  Stream<List<Category>> watchAll() => _repository.watchAllCategories();

  Future<Category?> getById(String id) async {
    final all = await _repository.getCategories();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> add(Category category) => _repository.insertCategory(category);

  Future<bool> update(Category category) => _repository.updateCategory(category);

  Future<int> delete(Category category) => _repository.deleteCategory(category);
}
