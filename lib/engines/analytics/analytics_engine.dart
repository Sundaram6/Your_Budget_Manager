import '../../core/enums.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import 'models/analytics_models.dart';

class AnalyticsEngine {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  AnalyticsEngine(this._transactionRepository, this._categoryRepository);

  /// Returns monthly total expenses in integer paise.
  Future<int> getMonthlyTotal(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
    
    return txs
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount.value);
  }

  /// Returns category breakdown with totals in integer paise.
  Future<List<CategoryBreakdown>> getCategoryBreakdown(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    
    final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
    final categories = await _categoryRepository.getCategories();
    
    final expenses = txs.where((t) => t.type == TransactionType.expense).toList();
    final totalExpense = expenses.fold<int>(0, (sum, t) => sum + t.amount.value);
    
    if (totalExpense == 0) return [];

    final categoryTotals = <String, int>{};
    for (final tx in expenses) {
      categoryTotals[tx.categoryId] = (categoryTotals[tx.categoryId] ?? 0) + tx.amount.value;
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

  /// Returns daily trend with totals in integer paise.
  Future<List<DailyTrend>> getDailyTrend(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    
    final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
    final expenses = txs.where((t) => t.type == TransactionType.expense).toList();
    
    final dailyTotals = <int, int>{};
    for (var i = 1; i <= end.day; i++) {
      dailyTotals[i] = 0;
    }
    
    for (final tx in expenses) {
      dailyTotals[tx.date.day] = (dailyTotals[tx.date.day] ?? 0) + tx.amount.value;
    }

    return dailyTotals.entries.map((e) => DailyTrend(
      date: DateTime(year, month, e.key),
      total: e.value,
    )).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns month-over-month comparison in integer paise.
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

  /// Sum of income transactions for the month in integer paise.
  Future<int> getMonthlyIncome(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
    return txs
        .where((t) => t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount.value);
  }

  /// Returns (date, amountPaise) of the highest-spending day in the month.
  Future<(DateTime, int)?> getTopSpendingDay(int year, int month) async {
    final trends = await getDailyTrend(year, month);
    if (trends.isEmpty) return null;
    final top = trends.reduce((a, b) => a.total >= b.total ? a : b);
    if (top.total <= 0) return null;
    return (top.date, top.total);
  }

  /// Count of days with zero expense in the month.
  Future<int> getZeroExpenseDays(int year, int month) async {
    final trends = await getDailyTrend(year, month);
    return trends.where((t) => t.total == 0).length;
  }

  /// Returns current consecutive zero-expense streak (days ending today or end of selected month).
  Future<int> getCurrentZeroExpenseStreak({int? year, int? month}) async {
    final now = DateTime.now();
    final endYear = year ?? now.year;
    final endMonth = month ?? now.month;
    final endDay = (endYear == now.year && endMonth == now.month) ? now.day : DateTime(endYear, endMonth + 1, 0).day;

    int streak = 0;
    // Walk backwards from end of the month (or today)
    for (int day = endDay; day >= 1; day--) {
      final date = DateTime(endYear, endMonth, day);
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      final txs = await _transactionRepository.watchTransactionsByDateRange(start, end).first;
      final dayExpenses = txs.where((t) => t.type == TransactionType.expense).fold<int>(0, (s, t) => s + t.amount.value);
      if (dayExpenses == 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Returns (categoryName, totalPaise) of the highest-spending category in the month.
  Future<(String, int)?> getMostSpentCategory(int year, int month) async {
    final breakdown = await getCategoryBreakdown(year, month);
    if (breakdown.isEmpty) return null;
    final top = breakdown.first; // already sorted desc
    return (top.categoryName, top.total);
  }
}
