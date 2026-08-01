import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../engines/analytics/analytics_engine_provider.dart';
import '../../../../engines/analytics/models/analytics_models.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../../../engines/budget/models/budget_progress.dart';
import '../../../../engines/budget/models/daily_allowance.dart';
import '../../../../engines/expense/expense_engine_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';

part 'dashboard_controller.freezed.dart';
part 'dashboard_controller.g.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    required double monthlyTotal,
    required DailyAllowance dailyAllowance,
    required List<CategoryBreakdown> categoryBreakdown,
    required List<BudgetProgress> budgetProgress,
    required List<Transaction> recentTransactions,
  }) = _DashboardState;
}

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<DashboardState> build() async {
    return _loadDashboard();
  }

  Future<DashboardState> _loadDashboard() async {
    final now = DateTime.now();
    
    final analyticsEngine = ref.watch(analyticsEngineProvider);
    final budgetEngine = ref.watch(budgetEngineProvider);
    final expenseEngine = ref.watch(expenseEngineProvider);

    final monthlyTotal = await analyticsEngine.getMonthlyTotal(now.year, now.month);
    final dailyAllowance = await budgetEngine.calculateDailyAllowance(date: now);
    final categoryBreakdown = await analyticsEngine.getCategoryBreakdown(now.year, now.month);
    
    // We need budget progress for all active budgets
    final activeBudgets = await budgetEngine.watchActiveBudgets().first;
    final budgetProgressFutures = activeBudgets.map((b) => budgetEngine.calculateProgress(b.categoryId, month: now));
    final budgetProgress = await Future.wait(budgetProgressFutures);
    
    // Recent transactions
    final allTransactions = await expenseEngine.getTransactionsByMonth(now);
    final recentTransactions = allTransactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final limitedTransactions = recentTransactions.take(5).toList();

    return DashboardState(
      monthlyTotal: monthlyTotal,
      dailyAllowance: dailyAllowance,
      categoryBreakdown: categoryBreakdown,
      budgetProgress: budgetProgress,
      recentTransactions: limitedTransactions,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboard());
  }
}
