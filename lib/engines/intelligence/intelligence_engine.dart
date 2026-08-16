import 'dart:math';
import 'package:intl/intl.dart';

import '../../core/enums.dart';
import '../../core/utils/currency_formatter.dart';
import '../../database/daos/category_dao.dart';
import '../../database/daos/transaction_dao.dart';
import '../../repositories/recurring_repository.dart';
import '../analytics/analytics_engine.dart';
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
  final RecurringRepository? _recurringRepository;
  final AnalyticsEngine? _analyticsEngine;

  IntelligenceEngine({
    BudgetEngine? budgetEngine,
    SavingsEngine? savingsEngine,
    ExpenseEngine? expenseEngine,
    TransactionDao? transactionDao,
    CategoryDao? categoryDao,
    RecurringRepository? recurringRepository,
    AnalyticsEngine? analyticsEngine,
  })  : _budgetEngine = budgetEngine,
        _savingsEngine = savingsEngine,
        _expenseEngine = expenseEngine,
        _transactionDao = transactionDao,
        _categoryDao = categoryDao,
        _recurringRepository = recurringRepository,
        _analyticsEngine = analyticsEngine;

  /// Calculate Budget Health Score: -100 to 100
  /// Scoring Bands:
  /// - Healthy (80 to 100): Utilization <= 70%, comfortable daily allowance, active savings goals.
  /// - Caution (50 to 79): Utilization 70% - 90%, tight daily allowance or high fixed recurring ratio.
  /// - Over-Budget (0 to 49): Utilization 90% - 125%, budget limit reached/exceeded.
  /// - Severely Over-Budget (< 0 down to -100): Utilization > 125%, deep deficit.
  ///
  /// Considers:
  /// - Forward-looking budget progress (spent + upcoming recurring + committed savings)
  /// - Fixed recurring cost ratio penalty (> 50% of budget)
  /// - Savings discipline and goals (+10 for auto-deduct goals, -10 if no goals)
  /// - Daily allowance comfort (< ₹500/day penalty)
  Future<int> calculateBudgetHealthScore({DateTime? date}) async {
    final now = date ?? DateTime.now();

    if (_budgetEngine != null) {
      final progress = await _budgetEngine!.calculateBudgetProgress(date: now);
      if (progress != null && progress.limit > 0) {
        final double utilization = progress.totalCommitted / progress.limit;
        int baseScore;

        if (utilization <= 0.5) {
          // 0% - 50% utilization -> 90 to 100
          baseScore = 100 - (utilization * 20).round();
        } else if (utilization <= 0.8) {
          // 50% - 80% utilization -> 70 to 90
          final ratio = (utilization - 0.5) / 0.3;
          baseScore = 90 - (ratio * 20).round();
        } else if (utilization <= 1.0) {
          // 80% - 100% utilization -> 45 to 70 (Caution band)
          final ratio = (utilization - 0.8) / 0.2;
          baseScore = 70 - (ratio * 25).round();
        } else if (utilization <= 1.25) {
          // 100% - 125% utilization -> 0 to 45 (Over-Budget band)
          final ratio = (utilization - 1.0) / 0.25;
          baseScore = 45 - (ratio * 45).round();
        } else {
          // > 125% utilization -> negative scale down to -100 (Severely Over-Budget)
          final excessRatio = utilization - 1.25;
          baseScore = -min(100, (excessRatio * 100).round());
        }

        // Adjustments:
        // 1. High fixed recurring cost penalty (> 50% of monthly budget)
        if (progress.committedRecurring > 0 && (progress.committedRecurring / progress.limit > 0.5)) {
          baseScore -= 10;
        }

        // 2. Daily allowance comfort penalty
        final allowance = await _budgetEngine!.calculateDailyAllowance(date: now);
        if (allowance != null && !allowance.isOverBudget && allowance.amount < 50000) {
          baseScore -= 10;
        }

        // 3. Savings discipline adjustment
        if (_savingsEngine != null) {
          final goals = await _savingsEngine!.watchGoals().first;
          if (goals.isEmpty) {
            baseScore -= 10;
          } else {
            final hasAutoDeduct = goals.any((g) => g.status.toLowerCase() == 'active' && g.autoDeduct);
            if (hasAutoDeduct) {
              baseScore += 10;
            }
          }
        }

        return baseScore.clamp(-100, 100);
      }
    }

    // Fallback scoring when no budget is configured
    int score = 100;
    if (_expenseEngine != null) {
      final monthlySpendPaise = await _expenseEngine!.getMonthlyTotal(now, type: TransactionType.expense);
      if (monthlySpendPaise > 0) {
        score -= 10;
      }
    }

    if (_savingsEngine != null) {
      final goals = await _savingsEngine!.watchGoals().first;
      if (goals.isEmpty) {
        score -= 15;
      } else {
        final hasAutoDeduct = goals.any((g) => g.status.toLowerCase() == 'active' && g.autoDeduct);
        if (hasAutoDeduct) {
          score = min(100, score + 10);
        }
      }
    }

    return score.clamp(0, 100);
  }

  /// Calculates actionable survival-mode spending tip when over budget.
  Future<String?> getSurvivalModeTip({DateTime? date}) async {
    final now = date ?? DateTime.now();
    if (_budgetEngine == null) return null;

    final progress = await _budgetEngine!.calculateBudgetProgress(date: now);
    if (progress == null || !progress.isOverBudget) return null;

    final overPaise = progress.totalCommitted - progress.limit;
    final overFormatted = CurrencyFormatter.formatPaise(overPaise);
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = max(1, lastDay - now.day + 1);

    if (progress.spent > progress.limit) {
      if (daysRemaining > 1) {
        return "Survival Mode: You've exceeded your budget by $overFormatted with $daysRemaining days left. Freeze all discretionary spending (dining out, entertainment) to prevent further deficit.";
      } else {
        return "Survival Mode: Budget exceeded by $overFormatted on the last day of the month. Pause purchases until the new month begins.";
      }
    } else {
      return "Survival Mode: Committed bills and savings exceed budget by $overFormatted. Set daily spending to ₹0 to ensure scheduled commitments clear.";
    }
  }

  /// Daily Advice factoring in budget progress, recurring commitments, and savings.
  Future<String> getDailyAdvice() async {
    final now = DateTime.now();

    if (_budgetEngine == null) {
      return 'Start tracking your expenses to build smart money habits.';
    }

    final progress = await _budgetEngine!.calculateBudgetProgress(date: now);
    if (progress == null || progress.limit <= 0) {
      return 'Set a monthly budget to unlock daily allowance guidance.';
    }

    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = max(1, lastDay - now.day + 1);
    final allowance = await _budgetEngine!.calculateDailyAllowance(date: now);

    if (progress.isOverBudget) {
      final overPaise = progress.totalCommitted - progress.limit;
      final formattedOver = CurrencyFormatter.formatPaise(overPaise);
      if (progress.spent > progress.limit) {
        return "🚨 Budget exceeded by $formattedOver. Survival mode active: freeze non-essential spending.";
      } else {
        return "🚨 Over-committed by $formattedOver with upcoming bills & savings. Stick to essentials.";
      }
    } else if (daysRemaining == 1) {
      return 'Last day of the month — stay strong!';
    } else if (allowance != null && allowance.amount < 30000) { // < ₹300/day
      return 'Tight budget today. Stick to essentials.';
    } else if (progress.percentage > 0.8) {
      return "You're at ${(progress.percentage * 100).round()}% of committed budget. Slow down.";
    } else if (progress.committedRecurring > 0 && progress.remaining > 0) {
      final formattedRemaining = CurrencyFormatter.formatPaiseNoDecimals(progress.remaining);
      final formattedRecurring = CurrencyFormatter.formatPaiseNoDecimals(progress.committedRecurring);
      return "On track! $formattedRemaining left to spend after $formattedRecurring in upcoming bills.";
    } else {
      final formattedRemaining = CurrencyFormatter.formatPaiseNoDecimals(max(0, progress.remaining));
      return "You're on track! $formattedRemaining left to spend freely.";
    }
  }

  /// Category Warnings (spending > 40% or > 30%)
  Future<List<AiInsight>> analyzeCategorySpending() async {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    if (_transactionDao != null) {
      final startOfMonth = DateTime(now.year, now.month, 1);
      final transactions = await _transactionDao!.getTransactionsByDateRange(startOfMonth, now);
      final expenses = transactions
          .where((t) => t.type == 'expense' && (t.transferPairId == null || t.transferPairId!.isEmpty))
          .toList();
      final totalSpend = expenses.fold<int>(0, (sum, t) => sum + t.amount);

      if (totalSpend > 0) {
        final categoryMap = <String, int>{};
        for (final t in expenses) {
          categoryMap[t.categoryId] = (categoryMap[t.categoryId] ?? 0) + t.amount;
        }

        final sortedCategories = categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (final entry in sortedCategories.take(3)) {
          final ratio = entry.value / totalSpend;
          final pct = (ratio * 100).round();
          final category = _categoryDao != null ? await _categoryDao!.getCategoryById(entry.key) : null;
          final catName = category?.name ?? CategoryEngine.getDisplayName(entry.key);

          if (pct >= 40) {
            insights.add(AiInsight(
              id: 'cat_warning_${entry.key}',
              title: '$catName spending is high',
              description: "You've spent $pct% of your total spend on $catName this month.",
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

  /// Recurring Payment Commitment Insights
  Future<List<AiInsight>> analyzeRecurringCommitments() async {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    if (_analyticsEngine != null) {
      final summary = await _analyticsEngine!.getRecurringCommitments();
      if (summary.recurringCount > 0) {
        if (summary.upcomingRecurringThisMonthPaise > 0) {
          final formattedUpcoming = CurrencyFormatter.formatPaiseNoDecimals(summary.upcomingRecurringThisMonthPaise);
          insights.add(AiInsight(
            id: 'recurring_upcoming_due',
            title: 'Upcoming Recurring Bills',
            description: 'You have $formattedUpcoming in scheduled recurring bills due before month-end.',
            type: InsightType.tip,
            generatedAt: now,
            priority: 1,
          ));
        }

        if (summary.recurringExpenseRatio >= 40) {
          insights.add(AiInsight(
            id: 'recurring_high_fixed_costs',
            title: 'High Fixed Commitments',
            description: 'Recurring payments make up ${summary.recurringExpenseRatio.round()}% of your monthly expenses. Review unused subscriptions.',
            type: InsightType.warning,
            generatedAt: now,
            priority: 2,
          ));
        }
      }
    }

    return insights;
  }

  /// Savings Recommendations & Velocity
  Future<List<AiInsight>> generateSavingsRecommendations() async {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    if (_budgetEngine != null) {
      final progress = await _budgetEngine!.calculateBudgetProgress(date: now);
      if (progress != null && progress.limit > 0) {
        if (progress.percentage > 0.9) {
          insights.add(AiInsight(
            id: 'savings_pause_sub',
            title: 'Close to Budget Limit',
            description: "You're close to your budget limit. Consider pausing non-essential subscriptions.",
            type: InsightType.warning,
            generatedAt: now,
            priority: 1,
          ));
        }
      }
    }

    if (_savingsEngine != null) {
      final goals = await _savingsEngine!.watchGoals().first;
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

          if (goal.status.toLowerCase() == 'active' && goal.autoDeduct && goal.autoDeductAmount != null && goal.autoDeductAmount! > 0) {
            final formattedAuto = CurrencyFormatter.formatPaiseNoDecimals(goal.autoDeductAmount!);
            insights.add(AiInsight(
              id: 'savings_autodeduct_${goal.id}',
              title: '${goal.name} Auto-Saving',
              description: 'Auto-deducting $formattedAuto/mo towards ${goal.name} (${(ratio * 100).round()}% complete).',
              type: InsightType.tip,
              generatedAt: now,
              priority: 3,
            ));
          }

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

  /// Achievements & All Insights Consolidated
  Future<List<AiInsight>> generateInsights() async {
    final insights = <AiInsight>[];
    final now = DateTime.now();

    // Achievements
    if (_budgetEngine != null) {
      final overallBudget = await _budgetEngine!.getOverallBudget(now.month, now.year);
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
      final goals = await _savingsEngine!.watchGoals().first;
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

    // Category Warnings, Recurring Commitments & Savings Recommendations
    final catInsights = await analyzeCategorySpending();
    final recurringInsights = await analyzeRecurringCommitments();
    final savInsights = await generateSavingsRecommendations();

    // Survival Mode Active Insight (Highest Priority when over budget)
    if (_budgetEngine != null) {
      final progress = await _budgetEngine!.calculateBudgetProgress(date: now);
      if (progress != null && progress.isOverBudget) {
        final survivalTip = await getSurvivalModeTip(date: now);
        if (survivalTip != null) {
          insights.add(AiInsight(
            id: 'survival_mode_tip',
            title: '🚨 Survival Mode Active',
            description: survivalTip,
            type: InsightType.warning,
            generatedAt: now,
            priority: -1, // Topmost priority
          ));
        }
      }
    }

    insights.addAll(catInsights);
    insights.addAll(recurringInsights);
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

    // Sort by priority (lowest integer = highest priority first)
    insights.sort((a, b) => a.priority.compareTo(b.priority));
    return insights;
  }

  /// Generate deterministic insights for a specific past month.
  Future<List<AiInsight>> generateInsightsForMonth(int year, int month) async {
    if (_transactionDao == null) return [];
    final insights = <AiInsight>[];
    final generatedAt = DateTime(year, month, 1);

    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    final transactions = await _transactionDao!.getTransactionsByDateRange(startOfMonth, endOfMonth);

    if (transactions.isEmpty) return [];

    final expenses = transactions.where((t) => t.type == 'expense').toList();
    final incomes = transactions.where((t) => t.type == 'income').toList();
    final totalExpense = expenses.fold<int>(0, (s, t) => s + t.amount);
    final totalIncome = incomes.fold<int>(0, (s, t) => s + t.amount);

    // 1. Category breakdown insight
    if (expenses.isNotEmpty) {
      final catMap = <String, int>{};
      for (final t in expenses) {
        catMap[t.categoryId] = (catMap[t.categoryId] ?? 0) + t.amount;
      }
      final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      final category = _categoryDao != null ? await _categoryDao!.getCategoryById(top.key) : null;
      final catName = category?.name ?? CategoryEngine.getDisplayName(top.key);
      final pct = (top.value / totalExpense * 100).round();
      final potentialSavingPaise = (top.value * 0.2).round();
      insights.add(AiInsight(
        id: 'month_cat_${year}_$month',
        title: '$catName was your top expense',
        description:
            "You spent ${CurrencyFormatter.formatPaiseNoDecimals(top.value)} on $catName ($pct% of total). "
            "Cutting 20% here could save ~${CurrencyFormatter.formatPaiseNoDecimals(potentialSavingPaise)}.",
        type: pct >= 40 ? InsightType.warning : InsightType.tip,
        generatedAt: generatedAt,
        priority: 0,
      ));
    }

    // 2. Top spending day insight
    final dailyMap = <int, int>{};
    for (final t in expenses) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date).day;
      dailyMap[d] = (dailyMap[d] ?? 0) + t.amount;
    }
    if (dailyMap.isNotEmpty) {
      final topDay = dailyMap.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final topDate = DateTime(year, month, topDay.key);
      insights.add(AiInsight(
        id: 'month_topday_${year}_$month',
        title: 'Top spending day: ${DateFormat('d MMM').format(topDate)}',
        description:
            "You spent ${CurrencyFormatter.formatPaiseNoDecimals(topDay.value)} on ${DateFormat('d MMM').format(topDate)}. "
            "Consider spreading purchases to avoid single-day spikes.",
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
      final prevExpense = prevTxs.where((t) => t.type == 'expense').fold<int>(0, (s, t) => s + t.amount);
      final diff = totalExpense - prevExpense;
      final isLess = diff < 0;

      insights.add(AiInsight(
        id: 'month_savings_${year}_$month',
        title: savedAmount > 0 ? "You saved ${CurrencyFormatter.formatPaiseNoDecimals(savedAmount)}" : "Expenses exceeded income",
        description: isLess
            ? "Great! You spent ${CurrencyFormatter.formatPaiseNoDecimals(diff.abs())} less than last month ($savePct% of income saved)."
            : "You spent ${CurrencyFormatter.formatPaiseNoDecimals(diff.abs())} more than last month. Review your expenses.",
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
        description: "You had no expenses for $streak consecutive days at end of ${DateFormat('MMMM').format(generatedAt)}. Great discipline!",
        type: InsightType.achievement,
        generatedAt: generatedAt,
        priority: 3,
      ));
    }

    // 5. Transport/Food specific tip
    final catMap2 = <String, int>{};
    for (final t in expenses) {
      catMap2[t.categoryId] = (catMap2[t.categoryId] ?? 0) + t.amount;
    }
    final transportSpend = catMap2['cat_transport'] ?? 0;
    final foodSpend = catMap2['cat_food'] ?? 0;
    if (totalExpense > 0 && transportSpend / totalExpense > 0.2) {
      insights.add(AiInsight(
        id: 'month_transport_${year}_$month',
        title: 'High transport cost',
        description:
            'Transport was ${(transportSpend / totalExpense * 100).round()}% of expenses (${CurrencyFormatter.formatPaiseNoDecimals(transportSpend)}). '
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
            'Cooking at home more often could save ~${CurrencyFormatter.formatPaiseNoDecimals((foodSpend * 0.25).round())}.',
        type: InsightType.tip,
        generatedAt: generatedAt,
        priority: 4,
      ));
    }

    insights.sort((a, b) => a.priority.compareTo(b.priority));
    return insights;
  }
}
