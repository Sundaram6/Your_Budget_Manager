import 'package:uuid/uuid.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/categories/domain/repositories/category_repository.dart';

class CategoryEngine {
  static const String catGroceries = 'cat_groceries';
  static const String catShopping = 'cat_shopping';
  static const String catFood = 'cat_food';
  static const String catTransport = 'cat_transport';
  static const String catUtilities = 'cat_utilities';
  static const String catEntertainment = 'cat_entertainment';
  static const String catHealth = 'cat_health';
  static const String catIncome = 'cat_income';
  static const String catUncategorized = 'cat_uncategorized';
  static const String catMisc = 'cat_misc';

  static const Map<String, String> legacyNameToFixedIdMap = {
    'Groceries': catGroceries,
    'Online Shopping': catShopping,
    'Food Delivery': catFood,
    'Transport': catTransport,
    'Utilities': catUtilities,
    'Entertainment': catEntertainment,
    'Health & Medical': catHealth,
    'Income': catIncome,
    'Uncategorized': catUncategorized,
    'Miscellaneous': catMisc,
  };

  /// Resolves raw categoryId string to a clean human-readable Category Name.
  static String getDisplayName(String? categoryId, {List<Category>? categories}) {
    if (categoryId == null || categoryId.isEmpty) return 'Uncategorized';

    if (categories != null && categories.isNotEmpty) {
      final found = categories.where((c) => c.id == categoryId).firstOrNull;
      if (found != null && found.name.isNotEmpty) return found.name;
    }

    switch (categoryId) {
      case catGroceries:
        return 'Groceries';
      case catShopping:
        return 'Online Shopping';
      case catFood:
        return 'Food Delivery';
      case catTransport:
        return 'Transport';
      case catUtilities:
        return 'Utilities';
      case catEntertainment:
        return 'Entertainment';
      case catHealth:
        return 'Health & Medical';
      case catIncome:
        return 'Income';
      case catUncategorized:
        return 'Uncategorized';
      case catMisc:
        return 'Miscellaneous';
      default:
        if (categoryId.startsWith('cat_')) {
          final raw = categoryId.substring(4);
          if (raw.isNotEmpty) {
            return raw[0].toUpperCase() + raw.substring(1);
          }
        }
        return 'Uncategorized';
    }
  }


  final CategoryRepository _repository;
  final Uuid _uuid;

  CategoryEngine(this._repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();



  Future<void> seedDefaults() async {
    // Guardrail 1 — Atomicity: Migrate any legacy dynamic UUID default categories
    await _repository.migrateLegacyCategories(legacyNameToFixedIdMap);

    final existing = await _repository.getCategories();
    final existingIds = existing.map((c) => c.id).toSet();

    final now = DateTime.now();

    final defaults = [
      Category(
        id: catGroceries,
        name: 'Groceries',
        icon: 'shopping_cart',
        color: int.parse('10B981', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catShopping,
        name: 'Online Shopping',
        icon: 'shopping_bag',
        color: int.parse('8B5CF6', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catFood,
        name: 'Food Delivery',
        icon: 'restaurant',
        color: int.parse('F59E0B', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catTransport,
        name: 'Transport',
        icon: 'directions_car',
        color: int.parse('3B82F6', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catUtilities,
        name: 'Utilities',
        icon: 'bolt',
        color: int.parse('6366F1', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catEntertainment,
        name: 'Entertainment',
        icon: 'movie',
        color: int.parse('EC4899', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catHealth,
        name: 'Health & Medical',
        icon: 'medical_services',
        color: int.parse('EF4444', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catIncome,
        name: 'Income',
        icon: 'attach_money',
        color: int.parse('10B981', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catUncategorized,
        name: 'Uncategorized',
        icon: 'help_outline',
        color: int.parse('9CA3AF', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: catMisc,
        name: 'Miscellaneous',
        icon: 'category',
        color: int.parse('6B7280', radix: 16) | 0xFF000000,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final category in defaults) {
      if (!existingIds.contains(category.id)) {
        await _repository.insertCategory(category);
      }
    }

    final postSeedCategories = await _repository.getCategories();
    final postSeedIds = postSeedCategories.map((c) => c.id).toSet();
    final requiredIds = [
      catGroceries,
      catShopping,
      catFood,
      catTransport,
      catUtilities,
      catEntertainment,
      catHealth,
      catIncome,
      catUncategorized,
      catMisc,
    ];

    for (final reqId in requiredIds) {
      if (!postSeedIds.contains(reqId)) {
        assert(false, 'CRITICAL SEEDING ERROR: Required default category ID $reqId is missing from database.');
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

  Future<Category> createCustomCategory({
    required String name,
    required String icon,
    required int color,
  }) async {
    final now = DateTime.now();
    final cat = Category(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      color: color,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.insertCategory(cat);
    return cat;
  }

  Future<bool> update(Category category) => _repository.updateCategory(category);


  Future<int> delete(Category category) => _repository.deleteCategory(category);
}

