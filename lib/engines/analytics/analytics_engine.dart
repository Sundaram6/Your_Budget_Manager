import 'dart:math';

import '../../core/enums.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../models/recurring_transaction.dart';
import '../../repositories/recurring_repository.dart';
import '../recurring/recurring_engine.dart';
import '../savings/savings_engine.dart';
import 'models/analytics_models.dart';

class AnalyticsEngine {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final RecurringRepository? _recurringRepository;
  final SavingsEngine? _savingsEngine;

  AnalyticsEngine(
    this._transactionRepository,
    this._categoryRepository, {
    RecurringRepository? recurringRepository,
    SavingsEngine? savingsEngine,
  })  : _recurringRepository = recurringRepository,
        _savingsEngine = savingsEngine;

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

  /// Returns summary of recurring payment commitments.
  Future<RecurringCommitmentSummary> getRecurringCommitments({int? year, int? month}) async {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    if (_recurringRepository == null) {
      return const RecurringCommitmentSummary(
        totalMonthlyRecurringPaise: 0,
        upcomingRecurringThisMonthPaise: 0,
        recurringCount: 0,
        recurringExpenseRatio: 0.0,
      );
    }

    final all = await _recurringRepository!.watchAll().first;
    final activeExpenses = all.where((rt) => rt.isActive && rt.type.toLowerCase() == 'expense').toList();

    int totalMonthlyNormalizedPaise = 0;
    for (final rt in activeExpenses) {
      final freq = rt.frequency.toLowerCase();
      switch (freq) {
        case 'daily':
          totalMonthlyNormalizedPaise += rt.amountPaise * 30;
          break;
        case 'weekly':
          totalMonthlyNormalizedPaise += (rt.amountPaise * 52) ~/ 12;
          break;
        case 'biweekly':
          totalMonthlyNormalizedPaise += (rt.amountPaise * 26) ~/ 12;
          break;
        case 'yearly':
          totalMonthlyNormalizedPaise += rt.amountPaise ~/ 12;
          break;
        case 'custom':
          final interval = rt.intervalDays ?? 30;
          totalMonthlyNormalizedPaise += (rt.amountPaise * 30) ~/ max(1, interval);
          break;
        case 'monthly':
        default:
          totalMonthlyNormalizedPaise += rt.amountPaise;
          break;
      }
    }

    final upcomingThisMonthPaise = await getUpcomingRecurringTotal(targetYear, targetMonth);
    final monthlyTotalSpend = await getMonthlyTotal(targetYear, targetMonth);

    double ratio = 0.0;
    if (monthlyTotalSpend > 0) {
      ratio = (totalMonthlyNormalizedPaise / monthlyTotalSpend) * 100;
    }

    return RecurringCommitmentSummary(
      totalMonthlyRecurringPaise: totalMonthlyNormalizedPaise,
      upcomingRecurringThisMonthPaise: upcomingThisMonthPaise,
      recurringCount: activeExpenses.length,
      recurringExpenseRatio: ratio,
    );
  }

  /// Calculates upcoming recurring payments due in the given month.
  Future<int> getUpcomingRecurringTotal(int year, int month) async {
    if (_recurringRepository == null) return 0;

    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59, 999);

    final all = await _recurringRepository!.watchAll().first;
    int upcomingTotal = 0;

    for (final rt in all) {
      if (!rt.isActive || rt.type.toLowerCase() != 'expense') continue;
      if (rt.endDate != null && rt.endDate!.isBefore(startOfMonth)) continue;

      var occurrence = rt.nextDueDate;
      while (occurrence.compareTo(endOfMonth) <= 0) {
        if (rt.endDate != null && occurrence.isAfter(rt.endDate!)) break;

        if (occurrence.compareTo(startOfMonth) >= 0) {
          upcomingTotal += rt.amountPaise;
        }

        try {
          occurrence = RecurringEngine.calculateNextDue(occurrence, rt);
        } catch (_) {
          break;
        }
      }
    }

    return upcomingTotal;
  }

  /// Returns summary of all savings goals (both automated and manual).
  Future<SavingsAnalyticsSummary> getSavingsAnalytics() async {
    if (_savingsEngine == null) {
      return const SavingsAnalyticsSummary(
        totalGoalsCount: 0,
        activeGoalsCount: 0,
        totalSavedPaise: 0,
        totalTargetPaise: 0,
        monthlyCommittedAutoSavePaise: 0,
        overallProgressPercent: 0.0,
      );
    }

    final goals = await _savingsEngine!.watchGoals().first;
    final activeGoals = goals.where((g) => g.status.toLowerCase() == 'active').toList();

    final totalSaved = goals.fold<int>(0, (s, g) => s + g.currentAmount);
    final totalTarget = goals.fold<int>(0, (s, g) => s + g.targetAmount);

    final autoSaveCommitted = activeGoals
        .where((g) => g.autoDeduct && g.currentAmount < g.targetAmount && g.autoDeductAmount != null)
        .fold<int>(0, (s, g) => s + (g.autoDeductAmount ?? 0));

    final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0.0;

    return SavingsAnalyticsSummary(
      totalGoalsCount: goals.length,
      activeGoalsCount: activeGoals.length,
      totalSavedPaise: totalSaved,
      totalTargetPaise: totalTarget,
      monthlyCommittedAutoSavePaise: autoSaveCommitted,
      overallProgressPercent: overallProgress,
    );
  }

  /// Calculates total committed spend for the month: spent + upcoming recurring + committed savings.
  Future<int> getTotalCommittedMonthlySpend(int year, int month) async {
    final spent = await getMonthlyTotal(year, month);
    final upcomingRecurring = await getUpcomingRecurringTotal(year, month);
    final savingsSummary = await getSavingsAnalytics();
    return spent + upcomingRecurring + savingsSummary.monthlyCommittedAutoSavePaise;
  }
}
