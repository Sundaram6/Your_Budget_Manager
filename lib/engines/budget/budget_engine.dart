import 'package:uuid/uuid.dart';
import '../../core/errors/app_exception.dart';
import '../../features/budgets/domain/entities/budget.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/recurring/domain/repositories/recurring_repository.dart';
import '../expense/expense_engine.dart';
import 'models/budget_progress.dart';
import 'models/daily_allowance.dart';
import '../../features/transactions/domain/value_objects/amount.dart';
import '../../core/enums.dart';

class BudgetEngine {
  final BudgetRepository _budgetRepository;
  final ExpenseEngine _expenseEngine;
  final RecurringRepository _recurringRepository;
  final Uuid _uuid;

  BudgetEngine(
    this._budgetRepository,
    this._expenseEngine,
    this._recurringRepository, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  Future<Budget> setBudget({
    required String categoryId,
    required double amount,
    required DateTime month,
  }) async {
    if (amount <= 0) {
      throw const ValidationException('Amount must be greater than 0');
    }
    
    final activeBudgets = await watchActiveBudgets().first;
    try {
      final existingBudget = activeBudgets.firstWhere(
        (b) => b.categoryId == categoryId && b.startDate.year == month.year && b.startDate.month == month.month
      );
      final updatedBudget = existingBudget.copyWith(limit: Amount(amount));
      await _budgetRepository.updateBudget(updatedBudget);
      return updatedBudget;
    } catch (e) {
      final budget = Budget(
        id: _uuid.v4(),
        categoryId: categoryId,
        limit: Amount(amount),
        periodType: BudgetPeriodType.monthly,
        startDate: DateTime(month.year, month.month, 1),
        endDate: DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999),
      );
      await _budgetRepository.insertBudget(budget);
      return budget;
    }
  }

  Future<Budget?> getBudgetForCategory(String categoryId, DateTime month) async {
    final activeBudgets = await watchActiveBudgets().first;
    try {
      return activeBudgets.firstWhere(
        (b) => b.categoryId == categoryId && b.startDate.year == month.year && b.startDate.month == month.month
      );
    } catch (e) {
      return null;
    }
  }

  Stream<List<Budget>> watchActiveBudgets() {
    return _budgetRepository.watchActiveBudgets();
  }

  Future<BudgetProgress> calculateProgress(String categoryId, {DateTime? month}) async {
    final targetMonth = month ?? DateTime.now();
    final budget = await getBudgetForCategory(categoryId, targetMonth);
    final limit = budget?.limit.value ?? 0.0;
    
    final transactions = await _expenseEngine.getTransactionsByMonth(targetMonth);
    double spent = 0.0;
    for (final t in transactions) {
      if (t.categoryId == categoryId && t.type == TransactionType.expense) {
        spent += t.amount.value;
      }
    }

    if (limit == 0.0) {
      return BudgetProgress(
        spent: spent,
        limit: 0.0,
        percentage: spent > 0 ? 100.0 : 0.0,
        isOverBudget: spent > 0,
      );
    }

    final percentage = (spent / limit) * 100;
    
    return BudgetProgress(
      spent: spent,
      limit: limit,
      percentage: percentage,
      isOverBudget: spent > limit,
    );
  }

  Future<int> deleteBudget(Budget budget) async {
    return await _budgetRepository.deleteBudget(budget);
  }

  Future<DailyAllowance> calculateDailyAllowance({DateTime? date}) async {
    final now = date ?? DateTime.now();
    
    // totalIncome: sum of TransactionType.income for current month
    final totalIncome = await _expenseEngine.getMonthlyTotal(now, type: TransactionType.income);
    
    // fixedBills: sum of active recurring transactions marked as expenses
    final activeRecurring = await _recurringRepository.getActive();
    double fixedBills = 0.0;
    for (final r in activeRecurring) {
      if (r.type == TransactionType.expense) {
        fixedBills += r.amount.value;
      }
    }
    
    // savingsGoalContribution: 0 in Phase 1
    const double savingsGoalContribution = 0.0;
    
    // spentSoFarThisMonth: sum of TransactionType.expense for current month
    final spentSoFarThisMonth = await _expenseEngine.getMonthlyTotal(now, type: TransactionType.expense);
    
    // remaining = totalIncome - fixedBills - savingsGoalContribution - spentSoFarThisMonth
    final remaining = totalIncome - fixedBills - savingsGoalContribution - spentSoFarThisMonth;
    
    // daysLeft = daysRemainingInMonth (min 1 to avoid division by zero)
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysRemaining = lastDay.day - now.day + 1; 
    final daysLeft = daysRemaining > 0 ? daysRemaining : 1;
    
    final dailyAllowance = remaining / daysLeft;
    
    return DailyAllowance(
      amount: dailyAllowance,
      remaining: remaining,
      daysLeft: daysLeft,
      isHealthy: dailyAllowance > 0,
    );
  }
}
