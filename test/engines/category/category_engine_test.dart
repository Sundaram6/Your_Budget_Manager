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
      name: 'Test',
      icon: 'test',
      color: 0xFF000000,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    test('seedDefaults() inserts default categories when empty', () async {
      when(() => mockRepository.getCategories()).thenAnswer((_) async => []);
      when(() => mockRepository.insertCategory(any())).thenAnswer((_) async => 1);
      when(() => mockUuid.v4()).thenReturn('fake-uuid');

      await engine.seedDefaults();

      verify(() => mockRepository.getCategories()).called(1);
      verify(() => mockRepository.insertCategory(any())).called(6);
    });

    test('seedDefaults() does not insert when not empty', () async {
      when(() => mockRepository.getCategories()).thenAnswer((_) async => [dummyCategory]);

      await engine.seedDefaults();

      verify(() => mockRepository.getCategories()).called(1);
      verifyNever(() => mockRepository.insertCategory(any()));
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

    test('add() inserts category', () async {
      when(() => mockRepository.insertCategory(dummyCategory)).thenAnswer((_) async => 1);

      final result = await engine.add(dummyCategory);

      expect(result, 1);
      verify(() => mockRepository.insertCategory(dummyCategory)).called(1);
    });

    test('update() updates category', () async {
      when(() => mockRepository.updateCategory(dummyCategory)).thenAnswer((_) async => true);

      final result = await engine.update(dummyCategory);

      expect(result, true);
      verify(() => mockRepository.updateCategory(dummyCategory)).called(1);
    });

    test('delete() deletes category', () async {
      when(() => mockRepository.deleteCategory(dummyCategory)).thenAnswer((_) async => 1);

      final result = await engine.delete(dummyCategory);

      expect(result, 1);
      verify(() => mockRepository.deleteCategory(dummyCategory)).called(1);
    });
  });
}
