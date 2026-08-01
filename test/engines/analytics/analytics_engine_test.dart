import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/categories/domain/repositories/category_repository.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late AnalyticsEngine analyticsEngine;
  late MockTransactionRepository mockTransactionRepository;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockCategoryRepository = MockCategoryRepository();
    analyticsEngine = AnalyticsEngine(
      mockTransactionRepository,
      mockCategoryRepository,
    );
  });

  group('AnalyticsEngine', () {
    const cat1 = Category(id: 'c1', name: 'Food', color: 1, icon: 'icon1');
    const cat2 = Category(id: 'c2', name: 'Transport', color: 2, icon: 'icon2');

    final t1 = Transaction(
      id: 't1',
      amount: const Amount(50),
      date: DateTime(2023, 10, 5),
      categoryId: 'c1',
      type: TransactionType.expense,
    );
    final t2 = Transaction(
      id: 't2',
      amount: const Amount(150),
      date: DateTime(2023, 10, 15),
      categoryId: 'c2',
      type: TransactionType.expense,
    );
    final t3 = Transaction(
      id: 't3',
      amount: const Amount(100),
      date: DateTime(2023, 10, 20),
      categoryId: 'c1',
      type: TransactionType.expense,
    );
    final tIncome = Transaction(
      id: 't4',
      amount: const Amount(500),
      date: DateTime(2023, 10, 10),
      categoryId: 'c3',
      type: TransactionType.income,
    );

    test('getMonthlyTotal should return sum of expenses only', () async {
      when(() => mockTransactionRepository.watchTransactionsByDateRange(any(), any()))
          .thenAnswer((_) => Stream.value([t1, t2, t3, tIncome]));

      final total = await analyticsEngine.getMonthlyTotal(2023, 10);
      expect(total, 300.0);
    });

    test('getCategoryBreakdown should return grouped expenses with percentages sorted by total descending', () async {
      when(() => mockTransactionRepository.watchTransactionsByDateRange(any(), any()))
          .thenAnswer((_) => Stream.value([t1, t2, t3, tIncome]));
      when(() => mockCategoryRepository.getCategories())
          .thenAnswer((_) async => [cat1, cat2]);

      final breakdown = await analyticsEngine.getCategoryBreakdown(2023, 10);
      
      expect(breakdown.length, 2);
      
      expect(breakdown[0].categoryId, 'c1');
      expect(breakdown[0].total, 150.0);
      expect(breakdown[0].percentage, 50.0);

      expect(breakdown[1].categoryId, 'c2');
      expect(breakdown[1].total, 150.0);
      expect(breakdown[1].percentage, 50.0);
    });

    test('getDailyTrend should return daily totals for expenses', () async {
      when(() => mockTransactionRepository.watchTransactionsByDateRange(any(), any()))
          .thenAnswer((_) => Stream.value([t1, t2, t3, tIncome]));

      final trend = await analyticsEngine.getDailyTrend(2023, 10);
      
      expect(trend.length, 31);
      
      expect(trend.firstWhere((e) => e.date.day == 5).total, 50.0);
      expect(trend.firstWhere((e) => e.date.day == 15).total, 150.0);
      expect(trend.firstWhere((e) => e.date.day == 20).total, 100.0);
      expect(trend.firstWhere((e) => e.date.day == 10).total, 0.0); // Income is ignored
    });

    group('getMonthOverMonthComparison', () {
      setUp(() {
        registerFallbackValue(DateTime(2000));
      });

      test('calculates correct positive change', () async {
        // Mock current month (Oct)
        when(() => mockTransactionRepository.watchTransactionsByDateRange(
          DateTime(2023, 10, 1),
          DateTime(2023, 11, 0, 23, 59, 59, 999),
        )).thenAnswer((_) => Stream.value([
          Transaction(id: 'tx_cur', amount: const Amount(200), date: DateTime(2023, 10, 1), categoryId: 'c1', type: TransactionType.expense)
        ]));

        // Mock prev month (Sep)
        when(() => mockTransactionRepository.watchTransactionsByDateRange(
          DateTime(2023, 9, 1),
          DateTime(2023, 10, 0, 23, 59, 59, 999),
        )).thenAnswer((_) => Stream.value([
          Transaction(id: 'tx_prev', amount: const Amount(100), date: DateTime(2023, 9, 1), categoryId: 'c1', type: TransactionType.expense)
        ]));

        final comparison = await analyticsEngine.getMonthOverMonthComparison(2023, 10);
        
        expect(comparison.currentTotal, 200.0);
        expect(comparison.previousTotal, 100.0);
        expect(comparison.changePercent, 100.0);
      });

      test('calculates correct negative change', () async {
        when(() => mockTransactionRepository.watchTransactionsByDateRange(
          DateTime(2023, 10, 1),
          DateTime(2023, 11, 0, 23, 59, 59, 999),
        )).thenAnswer((_) => Stream.value([
          Transaction(id: 'tx_cur', amount: const Amount(50), date: DateTime(2023, 10, 1), categoryId: 'c1', type: TransactionType.expense)
        ]));

        when(() => mockTransactionRepository.watchTransactionsByDateRange(
          DateTime(2023, 9, 1),
          DateTime(2023, 10, 0, 23, 59, 59, 999),
        )).thenAnswer((_) => Stream.value([
          Transaction(id: 'tx_prev', amount: const Amount(100), date: DateTime(2023, 9, 1), categoryId: 'c1', type: TransactionType.expense)
        ]));

        final comparison = await analyticsEngine.getMonthOverMonthComparison(2023, 10);
        
        expect(comparison.currentTotal, 50.0);
        expect(comparison.previousTotal, 100.0);
        expect(comparison.changePercent, -50.0);
      });

      test('handles division by zero if previous month was 0', () async {
        when(() => mockTransactionRepository.watchTransactionsByDateRange(
          DateTime(2023, 10, 1),
          DateTime(2023, 11, 0, 23, 59, 59, 999),
        )).thenAnswer((_) => Stream.value([
          Transaction(id: 'tx_cur', amount: const Amount(100), date: DateTime(2023, 10, 1), categoryId: 'c1', type: TransactionType.expense)
        ]));

        when(() => mockTransactionRepository.watchTransactionsByDateRange(
          DateTime(2023, 9, 1),
          DateTime(2023, 10, 0, 23, 59, 59, 999),
        )).thenAnswer((_) => Stream.value([]));

        final comparison = await analyticsEngine.getMonthOverMonthComparison(2023, 10);
        
        expect(comparison.currentTotal, 100.0);
        expect(comparison.previousTotal, 0.0);
        expect(comparison.changePercent, 100.0);
      });
      
      test('handles 0 current and 0 previous', () async {
        when(() => mockTransactionRepository.watchTransactionsByDateRange(any(), any()))
          .thenAnswer((_) => Stream.value([]));

        final comparison = await analyticsEngine.getMonthOverMonthComparison(2023, 10);
        
        expect(comparison.currentTotal, 0.0);
        expect(comparison.previousTotal, 0.0);
        expect(comparison.changePercent, 0.0);
      });
    });
  });
}
