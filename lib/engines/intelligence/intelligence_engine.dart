import 'dart:math';
import 'package:intl/intl.dart';

import '../../core/enums.dart';
import '../../database/daos/category_dao.dart';
import '../../database/daos/transaction_dao.dart';
import '../budget/budget_engine.dart';
import '../category/category_engine.dart';
import '../expense/expense_engine.dart';
import '../savings/savings_engine.dart';
import 'models/ai_insight.dart';

class IntelligenceEngine {
  final BudgetEngine? _budgetEngine;
  final SavingsEngine? _savingsEngine;
  final ExpenseEngine? _expenseEngine;
  final TransactionDao? _transactionDao;
  final CategoryDao? _categoryDao;

  IntelligenceEngine({
    BudgetEngine? budgetEngine,
    SavingsEngine? savingsEngine,
    ExpenseEngine? expenseEngine,
    TransactionDao? transactionDao,
    CategoryDao? categoryDao,
  })  : _budgetEngine = budgetEngine,
        _savingsEngine = savingsEngine,
        _expenseEngine = expenseEngine,
        _transactionDao = transactionDao,
        _categoryDao = categoryDao;

  /// Calculate Budget Health Score: 0 - 100
  /// Rule 1:
  /// score = 100
  /// if (overBudget) score -= 40
  /// if (budgetProgress > 0.8) score -= 20
  /// else if (budgetProgress > 0.5) score -= 10
  /// if (noSavingsGoals) score -= 15
  /// if (dailyAllowance < 500) score -= 10 (i.e. < ₹500/day = 50000 paise)
  /// max(score, 0)
  Future<int> calculateBudgetHealthScore() async {
    int score = 100;
    final now = DateTime.now();

    if (_budgetEngine != null && _expenseEngine != null) {
      final overallBudget = await _budgetEngine.getOverallBudget(now.month, now.year);
      if (overallBudget != null && overallBudget.amount > 0) {
        final monthlySpendDouble = await _expenseEngine.getMonthlyTotal(now, type: TransactionType.expense);
        final monthlySpendPaise = (monthlySpendDouble * 100).round();
        final budgetAmountPaise = overallBudget.amount;

        final isOverBudget = monthlySpendPaise > budgetAmountPaise;
        final budgetProgress = monthlySpendPaise / budgetAmountPaise;

        if (isOverBudget) {
          score -= 40;
        } else if (budgetProgress > 0.8) {
          score -= 20;
        } else if (budgetProgress > 0.5) {
          score -= 10;
        }

        final allowance = await _budgetEngine.calculateDailyAllowance(date: now);
        if (allowance != null && allowance.amount < 50000) { // < ₹500/day
          score -= 10;
        }
      }
    }

    if (_savingsEngine != null) {
      final goals = await _savingsEngine.watchGoals().first;
      if (goals.isEmpty) {
        score -= 15;
      }
    }

    return max(0, score);
  }

  /// Rule 3: Daily Advice
  Future<String> getDailyAdvice() async {
    final now = DateTime.now();
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    if (_budgetEngine == null || _expenseEngine == null) {
      return "Start tracking your expenses to build smart money habits.";
    }

    final overallBudget = await _budgetEngine.getOverallBudget(now.month, now.year);
    if (overallBudget == null || overallBudget.amount <= 0) {
      return "Set a monthly budget to unlock daily allowance guidance.";
    }

    final monthlySpendDouble = await _expenseEngine.getMonthlyTotal(now, type: TransactionType.expense);
    final monthlySpendPaise = (monthlySpendDouble * 100).round();
    final budgetAmountPaise = overallBudget.amount;
    final remainingPaise = (budgetAmountPaise - monthlySpendPaise).clamp(0, budgetAmountPaise);

    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = max(1, lastDay - now.day + 1);

    final isOverBudget = monthlySpendPaise > budgetAmountPaise;
    final budgetProgress = monthlySpendPaise / budgetAmountPaise;

    final allowance = await _budgetEngine.calculateDailyAllowance(date: now);

    if (isOverBudget) {
      return "Budget exceeded. Pause non-essential spending today.";
    } else if (daysRemaining == 1) {
      return "Last day of the month — stay strong!";
    } else if (allowance != null && allowance.amount < 30000) { // < ₹300/day
      return "Tight budget today. Stick to essentials.";
    } else if (budgetProgress > 0.8) {
      return "You're at ${(budgetProgress * 100).round()}% of budget. Slow down.";
    } else {
      final remainingRupees = remainingPaise / 100;
      return "You're on track! ${currencyFormat.format(remainingRupees)} left to spend freely.";
    }
  }

  /// Rule 2: Category Warnings (spending > 40% or > 30%)
  Future<List<AiInsight>> analyzeCategorySpending() async {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    if (_transactionDao != null) {
      final startOfMonth = DateTime(now.year, now.month, 1);
      final transactions = await _transactionDao.getTransactionsByDateRange(startOfMonth, now);
      final expenses = transactions.where((t) => t.type == 'expense').toList();
      final totalSpend = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);

      if (totalSpend > 0) {
        final categoryMap = <String, double>{};
        for (final t in expenses) {
          categoryMap[t.categoryId] = (categoryMap[t.categoryId] ?? 0.0) + t.amount;
        }

        final sortedCategories = categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (final entry in sortedCategories.take(3)) {
          final ratio = entry.value / totalSpend;
          final pct = (ratio * 100).round();
          final category = _categoryDao != null ? await _categoryDao.getCategoryById(entry.key) : null;
          final catName = category?.name ?? CategoryEngine.getDisplayName(entry.key);

          if (pct >= 40) {
            insights.add(AiInsight(
              id: 'cat_warning_${entry.key}',
              title: '$catName spending is high',
              description: 'You\'ve spent $pct% of your total spend on $catName this month.',
              type: InsightType.warning,
              generatedAt: now,
              priority: 0,
            ));
          } else if (pct >= 30) {
            insights.add(AiInsight(
              id: 'cat_tip_${entry.key}',
              title: 'High $catName allocation',
              description: '$catName accounts for $pct% of your spending this month.',
              type: InsightType.tip,
              generatedAt: now,
              priority: 2,
            ));
          }
        }
      }
    }

    return insights;
  }

  /// Rule 4: Savings Recommendations
  Future<List<AiInsight>> generateSavingsRecommendations() async {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    if (_budgetEngine != null && _expenseEngine != null) {
      final overallBudget = await _budgetEngine.getOverallBudget(now.month, now.year);
      if (overallBudget != null && overallBudget.amount > 0) {
        final monthlySpendDouble = await _expenseEngine.getMonthlyTotal(now, type: TransactionType.expense);
        final monthlySpendPaise = (monthlySpendDouble * 100).round();

        if (monthlySpendPaise > (overallBudget.amount * 0.9)) {
          insights.add(AiInsight(
            id: 'savings_pause_sub',
            title: 'Close to Budget Limit',
            description: 'You\'re close to your budget limit. Consider pausing non-essential subscriptions.',
            type: InsightType.warning,
            generatedAt: now,
            priority: 1,
          ));
        }
      }
    }

    if (_savingsEngine != null) {
      final goals = await _savingsEngine.watchGoals().first;
      if (goals.isEmpty) {
        insights.add(AiInsight(
          id: 'savings_create_goal',
          title: 'Start a Savings Goal',
          description: 'Start a savings goal. Even ₹500/month builds ₹6,000/year.',
          type: InsightType.suggestion,
          generatedAt: now,
          priority: 3,
        ));
      } else {
        for (final goal in goals) {
          final target = goal.targetAmount;
          final current = goal.currentAmount;
          final ratio = target > 0 ? current / target : 0.0;

          if (goal.deadline != null && ratio < 0.5) {
            final deadlineDate = DateTime.fromMillisecondsSinceEpoch(goal.deadline!);
            final daysLeft = deadlineDate.difference(now).inDays;
            if (daysLeft >= 0 && daysLeft <= 30) {
              insights.add(AiInsight(
                id: 'savings_boost_${goal.id}',
                title: '${goal.name} deadline is near',
                description: 'Your ${goal.name} deadline is in $daysLeft days. Consider increasing your monthly auto-save.',
                type: InsightType.tip,
                generatedAt: now,
                priority: 2,
              ));
            }
          }
        }
      }
    }

    return insights;
  }

  /// Rule 5 Achievements & All Insights Consolidated
  Future<List<AiInsight>> generateInsights() async {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    // Achievements
    if (_budgetEngine != null) {
      final overallBudget = await _budgetEngine.getOverallBudget(now.month, now.year);
      if (overallBudget != null) {
        insights.add(AiInsight(
          id: 'achieve_first_budget',
          title: 'Budget Set',
          description: '🎉 You set your monthly budget!',
          type: InsightType.achievement,
          generatedAt: now,
          priority: 4,
        ));
      }
    }

    if (_savingsEngine != null) {
      final goals = await _savingsEngine.watchGoals().first;
      if (goals.isNotEmpty) {
        insights.add(AiInsight(
          id: 'achieve_first_goal',
          title: 'Savings Goal Active',
          description: '🎉 Savings goal active and tracking!',
          type: InsightType.achievement,
          generatedAt: now,
          priority: 4,
        ));
      }
    }

    // Category Warnings & Savings Recommendations
    final catInsights = await analyzeCategorySpending();
    final savInsights = await generateSavingsRecommendations();

    insights.addAll(catInsights);
    insights.addAll(savInsights);

    if (insights.isEmpty) {
      insights.add(AiInsight(
        id: 'default_tip',
        title: 'Welcome to Your Budget Manager',
        description: 'Start tracking expenses to see personalized insights.',
        type: InsightType.tip,
        generatedAt: now,
        priority: 5,
      ));
    }

    // Sort by priority (0 = highest priority first)
    insights.sort((a, b) => a.priority.compareTo(b.priority));
    return insights;
  }

  /// Generate deterministic insights for a specific past month.
  Future<List<AiInsight>> generateInsightsForMonth(int year, int month) async {
    if (_transactionDao == null) return [];
    final insights = <AiInsight>[];
    final generatedAt = DateTime(year, month, 1);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    final transactions = await _transactionDao!.getTransactionsByDateRange(startOfMonth, endOfMonth);

    if (transactions.isEmpty) return [];

    final expenses = transactions.where((t) => t.type == 'expense').toList();
    final incomes = transactions.where((t) => t.type == 'income').toList();
    final totalExpense = expenses.fold<double>(0.0, (s, t) => s + t.amount);
    final totalIncome = incomes.fold<double>(0.0, (s, t) => s + t.amount);

    // 1. Category breakdown insight
    if (expenses.isNotEmpty) {
      final catMap = <String, double>{};
      for (final t in expenses) {
        catMap[t.categoryId] = (catMap[t.categoryId] ?? 0.0) + t.amount;
      }
      final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      final category = _categoryDao != null ? await _categoryDao.getCategoryById(top.key) : null;
      final catName = category?.name ?? CategoryEngine.getDisplayName(top.key);
      final pct = (top.value / totalExpense * 100).round();
      final potentialSaving = (top.value * 0.2).round();
      insights.add(AiInsight(
        id: 'month_cat_${year}_$month',
        title: '$catName was your top expense',
        description:
            'You spent ${currencyFormat.format(top.value)} on $catName ($pct% of total). '
            'Cutting 20% here could save ~${currencyFormat.format(potentialSaving)}.',
        type: pct >= 40 ? InsightType.warning : InsightType.tip,
        generatedAt: generatedAt,
        priority: 0,
      ));
    }

    // 2. Top spending day insight
    final dailyMap = <int, double>{};
    for (final t in expenses) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date).day;
      dailyMap[d] = (dailyMap[d] ?? 0.0) + t.amount;
    }
    if (dailyMap.isNotEmpty) {
      final topDay = dailyMap.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final topDate = DateTime(year, month, topDay.key);
      insights.add(AiInsight(
        id: 'month_topday_${year}_$month',
        title: 'Top spending day: ${DateFormat('d MMM').format(topDate)}',
        description:
            'You spent ${currencyFormat.format(topDay.value)} on ${DateFormat('d MMM').format(topDate)}. '
            'Consider spreading purchases to avoid single-day spikes.',
        type: InsightType.tip,
        generatedAt: generatedAt,
        priority: 1,
      ));
    }

    // 3. Savings comparison to previous month
    if (totalIncome > 0) {
      final savedAmount = totalIncome - totalExpense;
      final savePct = (savedAmount / totalIncome * 100).clamp(-100.0, 100.0).round();
      final prevMonth = month - 1 == 0 ? 12 : month - 1;
      final prevYear = month - 1 == 0 ? year - 1 : year;
      final prevStart = DateTime(prevYear, prevMonth, 1);
      final prevEnd = DateTime(prevYear, prevMonth + 1, 0, 23, 59, 59, 999);
      final prevTxs = await _transactionDao!.getTransactionsByDateRange(prevStart, prevEnd);
      final prevExpense = prevTxs.where((t) => t.type == 'expense').fold<double>(0.0, (s, t) => s + t.amount);
      final diff = totalExpense - prevExpense;
      final isLess = diff < 0;

      insights.add(AiInsight(
        id: 'month_savings_${year}_$month',
        title: savedAmount > 0 ? 'You saved ${currencyFormat.format(savedAmount)}' : 'Expenses exceeded income',
        description: isLess
            ? 'Great! You spent ${currencyFormat.format(diff.abs())} less than last month ($savePct% of income saved).'
            : 'You spent ${currencyFormat.format(diff.abs())} more than last month. Review your expenses.',
        type: savedAmount > 0 && isLess ? InsightType.achievement : InsightType.warning,
        generatedAt: generatedAt,
        priority: 2,
      ));
    }

    // 4. Zero expense streak
    final daysInMonth = endOfMonth.day;
    int streak = 0;
    for (int day = daysInMonth; day >= 1; day--) {
      final dayExpenses = expenses.where((t) =>
          DateTime.fromMillisecondsSinceEpoch(t.date).day == day).toList();
      if (dayExpenses.isEmpty) {
        streak++;
      } else {
        break;
      }
    }
    if (streak > 0) {
      insights.add(AiInsight(
        id: 'month_streak_${year}_$month',
        title: '$streak-day zero spend streak!',
        description: 'You had no expenses for $streak consecutive days at end of ${DateFormat('MMMM').format(generatedAt)}. Great discipline!',
        type: InsightType.achievement,
        generatedAt: generatedAt,
        priority: 3,
      ));
    }

    // 5. Transport/Food specific tip
    final catMap2 = <String, double>{};
    for (final t in expenses) {
      catMap2[t.categoryId] = (catMap2[t.categoryId] ?? 0.0) + t.amount;
    }
    final transportSpend = catMap2['cat_transport'] ?? 0.0;
    final foodSpend = catMap2['cat_food'] ?? 0.0;
    if (totalExpense > 0 && transportSpend / totalExpense > 0.2) {
      insights.add(AiInsight(
        id: 'month_transport_${year}_$month',
        title: 'High transport cost',
        description:
            'Transport was ${(transportSpend / totalExpense * 100).round()}% of expenses (${currencyFormat.format(transportSpend)}). '
            'Using metro/bus on some trips could significantly reduce this.',
        type: InsightType.tip,
        generatedAt: generatedAt,
        priority: 4,
      ));
    }
    if (totalExpense > 0 && foodSpend / totalExpense > 0.3) {
      insights.add(AiInsight(
        id: 'month_food_${year}_$month',
        title: 'Food spending is high',
        description:
            'Food & Dining was ${(foodSpend / totalExpense * 100).round()}% of expenses. '
            'Cooking at home more often could save ~${currencyFormat.format((foodSpend * 0.25).round())}.',
        type: InsightType.tip,
        generatedAt: generatedAt,
        priority: 4,
      ));
    }

    insights.sort((a, b) => a.priority.compareTo(b.priority));
    return insights;
  }
}
