import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/categories/domain/repositories/category_repository.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockUuid extends Mock implements Uuid {}
class FakeCategory extends Fake implements Category {}

void main() {
  late CategoryEngine engine;
  late MockCategoryRepository mockRepository;
  late MockUuid mockUuid;

  setUpAll(() {
    registerFallbackValue(FakeCategory());
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    mockUuid = MockUuid();
    engine = CategoryEngine(mockRepository, uuid: mockUuid);
  });

  group('CategoryEngine', () {
    final now = DateTime.now();
    final dummyCategory = Category(
      id: 'test-id',
      name: 'Test Custom Category',
      icon: 'test',
      color: 0xFF000000,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    test('seedDefaults() migrates legacy categories and inserts fixed default categories when missing', () async {
      final now = DateTime.now();
      final allDefaults = [
        Category(id: CategoryEngine.catGroceries, name: 'Groceries', icon: 'cart', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catShopping, name: 'Online Shopping', icon: 'bag', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catFood, name: 'Food Delivery', icon: 'food', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catTransport, name: 'Transport', icon: 'car', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catUtilities, name: 'Utilities', icon: 'bolt', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catEntertainment, name: 'Entertainment', icon: 'movie', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catIncome, name: 'Income', icon: 'money', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catUncategorized, name: 'Uncategorized', icon: 'help', color: 0, isDefault: true, createdAt: now, updatedAt: now),
      ];

      when(() => mockRepository.migrateLegacyCategories(any())).thenAnswer((_) async {});
      when(() => mockRepository.getCategories()).thenAnswer((_) async => []);
      when(() => mockRepository.insertCategory(any())).thenAnswer((_) async {
        when(() => mockRepository.getCategories()).thenAnswer((_) async => allDefaults);
        return 1;
      });

      await engine.seedDefaults();

      verify(() => mockRepository.migrateLegacyCategories(CategoryEngine.legacyNameToFixedIdMap)).called(1);
      verify(() => mockRepository.insertCategory(any())).called(8);
    });

    test('seedDefaults() ensures fixed default category IDs are seeded even if custom category with same name exists', () async {
      final userCustomGroceries = Category(
        id: 'user-custom-123',
        name: 'Groceries',
        icon: 'custom',
        color: 0xFF123456,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      );

      final allDefaults = [
        userCustomGroceries,

        Category(id: CategoryEngine.catGroceries, name: 'Groceries', icon: 'cart', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catShopping, name: 'Online Shopping', icon: 'bag', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catFood, name: 'Food Delivery', icon: 'food', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catTransport, name: 'Transport', icon: 'car', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catUtilities, name: 'Utilities', icon: 'bolt', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catEntertainment, name: 'Entertainment', icon: 'movie', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catIncome, name: 'Income', icon: 'money', color: 0, isDefault: true, createdAt: now, updatedAt: now),
        Category(id: CategoryEngine.catUncategorized, name: 'Uncategorized', icon: 'help', color: 0, isDefault: true, createdAt: now, updatedAt: now),
      ];

      when(() => mockRepository.migrateLegacyCategories(any())).thenAnswer((_) async {});
      when(() => mockRepository.getCategories()).thenAnswer((_) async => [userCustomGroceries]);
      when(() => mockRepository.insertCategory(any())).thenAnswer((_) async {
        when(() => mockRepository.getCategories()).thenAnswer((_) async => allDefaults);
        return 1;
      });

      await engine.seedDefaults();

      // All 8 fixed default category IDs are seeded unconditionally
      verify(() => mockRepository.insertCategory(any())).called(8);
    });


    test('getAll() returns all categories', () async {
      when(() => mockRepository.getCategories()).thenAnswer((_) async => [dummyCategory]);

      final result = await engine.getAll();

      expect(result, [dummyCategory]);
      verify(() => mockRepository.getCategories()).called(1);
    });

    test('watchAll() watches all categories', () {
      final stream = Stream.value([dummyCategory]);
      when(() => mockRepository.watchAllCategories()).thenAnswer((_) => stream);

      final result = engine.watchAll();

      expect(result, stream);
      verify(() => mockRepository.watchAllCategories()).called(1);
    });

    test('getById() returns category if exists', () async {
      when(() => mockRepository.getCategories()).thenAnswer((_) async => [dummyCategory]);

      final result = await engine.getById('test-id');

      expect(result, dummyCategory);
    });

    test('getById() returns null if not exists', () async {
      when(() => mockRepository.getCategories()).thenAnswer((_) async => [dummyCategory]);

      final result = await engine.getById('other-id');

      expect(result, isNull);
    });
  });
}
