import 'dart:math';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/currency_formatter.dart';
import '../../database/app_database.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../models/recurring_transaction.dart';
import '../../repositories/recurring_repository.dart';
import '../expense/expense_engine.dart';
import '../recurring/recurring_engine.dart';
import '../savings/savings_engine.dart';
import 'models/budget_progress.dart';
import 'models/daily_allowance.dart';

class BudgetEngine {
  final BudgetRepository _budgetRepository;
  final ExpenseEngine _expenseEngine;
  final RecurringRepository? _recurringRepository;
  final SavingsEngine? _savingsEngine;
  final Logger _logger;
  final Uuid _uuid;

  BudgetEngine(
    this._budgetRepository,
    this._expenseEngine, {
    RecurringRepository? recurringRepository,
    SavingsEngine? savingsEngine,
    Logger? logger,
    Uuid? uuid,
  })  : _recurringRepository = recurringRepository,
        _savingsEngine = savingsEngine,
        _logger = logger ?? Logger(),
        _uuid = uuid ?? const Uuid();

  /// Gets overall budget for specified month/year.
  Future<Budget?> getOverallBudget(int month, int year) {
    return _budgetRepository.getOverallBudget(month, year);
  }

  /// Sets or updates a monthly budget (categoryId null = overall budget). Amount in paise.
  Future<Budget> setMonthlyBudget({
    String? categoryId,
    required int amountPaise,
    required int month,
    required int year,
  }) async {
    if (amountPaise <= 0) {
      throw const ValidationException('Budget amount must be greater than 0');
    }

    final existing = categoryId == null
        ? await _budgetRepository.getOverallBudget(month, year)
        : await _budgetRepository.getCategoryBudget(categoryId, month, year);

    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing != null) {
      final updated = existing.copyWith(
        amount: amountPaise,
      );
      await _budgetRepository.updateBudget(updated);
      return updated;
    } else {
      final newBudget = Budget(
        id: _uuid.v4(),
        name: categoryId == null ? 'Overall Monthly Budget' : 'Category Budget',
        categoryId: categoryId,
        amount: amountPaise,
        month: month,
        year: year,
        createdAt: now,
        type: 'monthly',
      );
      await _budgetRepository.insertBudget(newBudget);
      return newBudget;
    }
  }

  /// Calculates upcoming active recurring expenses due within the target month.
  /// Strictly filters for active expense rules and prevents double-counting with posted transactions.
  Future<int> getUpcomingRecurringSpend({int? month, int? year, DateTime? date}) async {
    if (_recurringRepository == null) return 0;

    final targetDate = date ?? DateTime(year ?? DateTime.now().year, month ?? DateTime.now().month, 1);
    final targetMonth = targetDate.month;
    final targetYear = targetDate.year;

    final startOfMonth = DateTime(targetYear, targetMonth, 1);
    final endOfMonth = DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59, 999);

    final allRecurring = await _recurringRepository!.watchAll().first;
    int totalUpcomingPaise = 0;

    for (final rt in allRecurring) {
      // Must be active and an expense
      if (!rt.isActive || rt.type.toLowerCase() != 'expense') continue;

      // If end date exists and has already passed before the month starts, skip
      if (rt.endDate != null && rt.endDate!.isBefore(startOfMonth)) continue;

      var occurrence = rt.nextDueDate;

      while (occurrence.compareTo(endOfMonth) <= 0) {
        if (rt.endDate != null && occurrence.isAfter(rt.endDate!)) {
          break;
        }

        if (occurrence.compareTo(startOfMonth) >= 0) {
          totalUpcomingPaise += rt.amountPaise;
        }

        try {
          occurrence = RecurringEngine.calculateNextDue(occurrence, rt);
        } catch (_) {
          break;
        }
      }
    }

    return totalUpcomingPaise;
  }

  /// Calculates scheduled unexecuted auto-deduct allocations for active, incomplete savings goals.
  /// Filters for autoDeduct == true, status == 'active', currentAmount < targetAmount,
  /// and lastAutoDeductedMonth != currentMonthKey (avoids double-counting if already deducted this month).
  Future<int> getCommittedSavings({String? budgetId, DateTime? date}) async {
    if (_savingsEngine == null) return 0;

    final targetDate = date ?? DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(targetDate);

    final goals = await _savingsEngine!.watchGoals().first;
    int totalCommittedSavings = 0;

    for (final goal in goals) {
      // Must be active, incomplete, and have auto-deduct enabled
      if (goal.status.toLowerCase() != 'active') continue;
      if (!goal.autoDeduct || goal.autoDeductAmount == null || goal.autoDeductAmount! <= 0) continue;
      if (goal.currentAmount >= goal.targetAmount) continue;

      // Filter by budgetId if specified and goal has budget linkage
      if (budgetId != null && goal.budgetId != null && goal.budgetId != budgetId) {
        continue;
      }

      // Check if already auto-deducted this month
      if (goal.lastAutoDeductedMonth == monthKey) continue;

      totalCommittedSavings += goal.autoDeductAmount!;
    }

    return totalCommittedSavings;
  }

  /// Calculates complete forward-looking BudgetProgress factoring in:
  /// (a) already posted transactions (spent)
  /// (b) upcoming unposted recurring payments due in the period (committedRecurring)
  /// (c) active unexecuted savings auto-deduct allocations (committedSavings)
  Future<BudgetProgress?> calculateBudgetProgress({int? month, int? year, DateTime? date}) async {
    final targetDate = date ?? DateTime(year ?? DateTime.now().year, month ?? DateTime.now().month, 1);
    final overallBudget = await _budgetRepository.getOverallBudget(targetDate.month, targetDate.year);

    if (overallBudget == null || overallBudget.amount <= 0) {
      return null;
    }

    final limit = overallBudget.amount;
    final spentPaise = await _expenseEngine.getMonthlyTotal(targetDate, type: TransactionType.expense);
    final committedRecurringPaise = await getUpcomingRecurringSpend(
      month: targetDate.month,
      year: targetDate.year,
      date: targetDate,
    );
    final committedSavingsPaise = await getCommittedSavings(
      budgetId: overallBudget.id,
      date: targetDate,
    );

    final totalCommittedPaise = spentPaise + committedRecurringPaise + committedSavingsPaise;
    final remainingPaise = limit - totalCommittedPaise; // signed
    final isOverBudget = totalCommittedPaise > limit;
    final percentage = limit > 0 ? (totalCommittedPaise / limit) : 0.0;

    return BudgetProgress(
      spent: spentPaise,
      limit: limit,
      percentage: percentage,
      isOverBudget: isOverBudget,
      committedRecurring: committedRecurringPaise,
      committedSavings: committedSavingsPaise,
      totalCommitted: totalCommittedPaise,
      remaining: remainingPaise,
    );
  }

  /// Calculates Daily Allowance using true effective remaining budget (budget minus total committed).
  /// Returns null if no overall monthly budget is set for current month.
  Future<DailyAllowance?> calculateDailyAllowance({DateTime? date}) async {
    final now = date ?? DateTime.now();

    final progress = await calculateBudgetProgress(date: now);
    if (progress == null) {
      return null; // Hide card when no budget is set
    }

    final remainingPaise = progress.remaining;
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysRemaining = max(1, lastDayOfMonth.day - now.day + 1);

    if (remainingPaise <= 0) {
      final overFormatted = CurrencyFormatter.formatPaise(-remainingPaise);
      final message = progress.spent > progress.limit
          ? 'Budget exceeded by $overFormatted. Pause non-essential spending.'
          : 'Budget over-committed by $overFormatted. Pause non-essential spending.';
      return DailyAllowance(
        amount: 0,
        message: message,
        isOverBudget: true,
        remaining: remainingPaise,
        daysLeft: daysRemaining,
      );
    }

    final dailyPaise = remainingPaise ~/ daysRemaining;
    final dailyFormatted = CurrencyFormatter.formatPaise(dailyPaise);

    return DailyAllowance(
      amount: dailyPaise,
      message: 'You can spend $dailyFormatted per day to stay in budget.',
      isOverBudget: false,
      remaining: remainingPaise,
      daysLeft: daysRemaining,
    );
  }

  /// Handles auto-rolling forward the previous month's budget to the current month on startup if missing.
  Future<void> handleMonthRollover({DateTime? date}) async {
    final now = date ?? DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final currentBudget = await _budgetRepository.getOverallBudget(currentMonth, currentYear);
    if (currentBudget != null) {
      return; // Budget already exists for current month
    }

    final prevDate = DateTime(currentYear, currentMonth - 1, 1);
    final prevBudget = await _budgetRepository.getOverallBudget(prevDate.month, prevDate.year);

    if (prevBudget != null && prevBudget.amount > 0) {
      final newBudget = Budget(
        id: _uuid.v4(),
        name: 'Overall Monthly Budget',
        categoryId: null,
        amount: prevBudget.amount,
        month: currentMonth,
        year: currentYear,
        createdAt: now.millisecondsSinceEpoch,
        type: 'monthly',
      );
      await _budgetRepository.insertBudget(newBudget);
      final rupees = (prevBudget.amount / 100).toStringAsFixed(0);
      _logger.i('Auto-created ₹$rupees budget for $currentMonth/$currentYear');
    }
  }

  /// Gets remaining overall budget in paise for specified month/year (signed).
  Future<int?> getRemainingBudget({int? month, int? year}) async {
    final targetDate = DateTime(year ?? DateTime.now().year, month ?? DateTime.now().month, 1);
    final progress = await calculateBudgetProgress(
      month: targetDate.month,
      year: targetDate.year,
      date: targetDate,
    );
    return progress?.remaining;
  }
}
