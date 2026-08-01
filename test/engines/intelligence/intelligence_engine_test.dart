import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/intelligence/models/insight.dart';

void main() {
  late AppDatabase db;
  late IntelligenceEngine engine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    engine = IntelligenceEngine(
      transactionDao: db.transactionDao,
      categoryDao: db.categoryDao,
    );
    // Insert a dummy category to prevent foreign key errors
    await db.into(db.categoriesTable).insert(
      CategoriesTableCompanion.insert(
        id: 'cat_food',
        name: 'Food',
        icon: 'fastfood',
        color: '#FF0000',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  });

  tearDown(() => db.close());

  group('IntelligenceEngine.generateMonthlyInsights', () {
    test('returns "Not enough data" when no transactions exist', () async {
      final insights = await engine.generateMonthlyInsights();
      expect(insights.length, 1);
      expect(insights.first.id, 'no_data');
    });

    test('generates top category insight', () async {
      final now = DateTime.now();
      await db.into(db.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          id: 'tx1',
          amount: 500,
          type: 'expense',
          categoryId: 'cat_food',
          date: now.millisecondsSinceEpoch,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        ),
      );

      final insights = await engine.generateMonthlyInsights();
      final topCat = insights.where((i) => i.id == 'top_category').toList();
      expect(topCat, isNotEmpty);
      expect(topCat.first.description, contains('Food'));
    });
  });
}
