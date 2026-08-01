import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/category_dao.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDao _dao;

  CategoryRepositoryImpl(this._dao);

  domain.Category _mapToDomain(db.Category entity) {
    return domain.Category(
      id: entity.id,
      name: entity.name,
      color: int.parse(entity.color),
      icon: entity.icon,
      isDefault: entity.isDefault,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(entity.updatedAt),
    );
  }

  db.Category _mapToDrift(domain.Category entity) {
    return db.Category(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color.toString(),
      isDefault: entity.isDefault,
      sortOrder: 0,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: entity.updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Stream<List<domain.Category>> watchAllCategories() {
    return _dao.watchAllCategories().map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Future<List<domain.Category>> getCategories() async {
    final list = await _dao.getCategories();
    return list.map(_mapToDomain).toList();
  }

  @override
  Future<List<domain.Category>> getDefaultCategories() async {
    final list = await _dao.getDefaultCategories();
    return list.map(_mapToDomain).toList();
  }

  @override
  Future<int> insertCategory(domain.Category category) {
    return _dao.insertCategory(_mapToDrift(category));
  }

  @override
  Future<bool> updateCategory(domain.Category category) {
    return _dao.updateCategory(_mapToDrift(category));
  }

  @override
  Future<int> deleteCategory(domain.Category category) {
    return _dao.deleteCategory(_mapToDrift(category));
  }
}
