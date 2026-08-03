import 'dart:math';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums.dart';
import '../../core/errors/app_exception.dart';
import '../../database/app_database.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../expense/expense_engine.dart';
import 'models/daily_allowance.dart';

class BudgetEngine {
  final BudgetRepository _budgetRepository;
  final ExpenseEngine _expenseEngine;
  final Logger _logger;
  final Uuid _uuid;

  BudgetEngine(
    this._budgetRepository,
    this._expenseEngine, {
    Logger? logger,
    Uuid? uuid,
  })  : _logger = logger ?? Logger(),
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

  /// Calculates Daily Allowance using integer math (paise).
  /// Returns null if no overall monthly budget is set for current month.
  Future<DailyAllowance?> calculateDailyAllowance({DateTime? date}) async {
    final now = date ?? DateTime.now();

    final overallBudget = await _budgetRepository.getOverallBudget(now.month, now.year);
    if (overallBudget == null || overallBudget.amount <= 0) {
      return null; // Hide card when no budget is set
    }

    final monthlyBudgetPaise = overallBudget.amount;

    // Get total expense spend for the month in paise
    final monthlyTotalDouble = await _expenseEngine.getMonthlyTotal(now, type: TransactionType.expense);
    final totalSpendThisMonthPaise = (monthlyTotalDouble * 100).round();

    final remainingPaise = monthlyBudgetPaise - totalSpendThisMonthPaise;

    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysRemaining = max(1, lastDayOfMonth.day - now.day + 1);

    if (remainingPaise <= 0) {
      final overBudgetRupees = (-remainingPaise / 100).toStringAsFixed(2);
      return DailyAllowance(
        amount: 0,
        message: 'Budget exceeded by ₹$overBudgetRupees. Pause spending.',
        isOverBudget: true,
        remaining: remainingPaise,
        daysLeft: daysRemaining,
      );
    }

    final dailyPaise = remainingPaise ~/ daysRemaining;
    final dailyRupees = (dailyPaise / 100).toStringAsFixed(2);

    return DailyAllowance(
      amount: dailyPaise,
      message: 'You can spend ₹$dailyRupees per day to stay in budget.',
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

  /// Gets remaining overall budget in paise for specified month/year.
  Future<int?> getRemainingBudget({int? month, int? year}) async {
    final targetDate = DateTime(year ?? DateTime.now().year, month ?? DateTime.now().month, 1);
    final overallBudget = await _budgetRepository.getOverallBudget(targetDate.month, targetDate.year);
    if (overallBudget == null) return null;

    final monthlyTotalDouble = await _expenseEngine.getMonthlyTotal(targetDate, type: TransactionType.expense);
    final spentPaise = (monthlyTotalDouble * 100).round();

    return overallBudget.amount - spentPaise;
  }
}
