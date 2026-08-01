import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../core/enums.dart';
import 'models/analytics_models.dart';

class AnalyticsEngine {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  AnalyticsEngine(this._transactionRepository, this._categoryRepository);

  Future<double> getMonthlyTotal(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
    
    return txs
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount.value.toDouble());
  }

  Future<List<CategoryBreakdown>> getCategoryBreakdown(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    
    final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
    final categories = await _categoryRepository.getCategories();
    
    final expenses = txs.where((t) => t.type == TransactionType.expense).toList();
    final totalExpense = expenses.fold<double>(0.0, (sum, t) => sum + t.amount.value.toDouble());
    
    if (totalExpense == 0) return [];

    final categoryTotals = <String, double>{};
    for (final tx in expenses) {
      categoryTotals[tx.categoryId] = (categoryTotals[tx.categoryId] ?? 0.0) + tx.amount.value.toDouble();
    }

    final breakdowns = <CategoryBreakdown>[];
    for (final entry in categoryTotals.entries) {
      final category = categories.firstWhere((c) => c.id == entry.key);
      breakdowns.add(CategoryBreakdown(
        categoryId: category.id,
        categoryName: category.name,
        color: category.color,
        icon: category.icon,
        total: entry.value,
        percentage: (entry.value / totalExpense) * 100,
      ));
    }
    
    breakdowns.sort((a, b) => b.total.compareTo(a.total));
    return breakdowns;
  }

  Future<List<DailyTrend>> getDailyTrend(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    
    final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
    final expenses = txs.where((t) => t.type == TransactionType.expense).toList();
    
    final dailyTotals = <int, double>{};
    for (var i = 1; i <= end.day; i++) {
      dailyTotals[i] = 0.0;
    }
    
    for (final tx in expenses) {
      dailyTotals[tx.date.day] = (dailyTotals[tx.date.day] ?? 0.0) + tx.amount.value.toDouble();
    }

    return dailyTotals.entries.map((e) => DailyTrend(
      date: DateTime(year, month, e.key),
      total: e.value,
    )).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<MonthOverMonthComparison> getMonthOverMonthComparison(int year, int month) async {
    final currentTotal = await getMonthlyTotal(year, month);
    
    var prevMonth = month - 1;
    var prevYear = year;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear = year - 1;
    }
    
    final previousTotal = await getMonthlyTotal(prevYear, prevMonth);
    
    double changePercent = 0.0;
    if (previousTotal > 0) {
      changePercent = ((currentTotal - previousTotal) / previousTotal) * 100;
    } else if (previousTotal == 0 && currentTotal > 0) {
      changePercent = 100.0;
    }
    
    return MonthOverMonthComparison(
      currentTotal: currentTotal,
      previousTotal: previousTotal,
      changePercent: changePercent,
    );
  }
}
