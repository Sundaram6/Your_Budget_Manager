import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../database/app_database.dart' hide Transaction;

import '../../../../engines/analytics/analytics_engine_provider.dart';
import '../../../../engines/analytics/models/analytics_models.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../../../engines/budget/models/budget_progress.dart';
import '../../../../engines/budget/models/daily_allowance.dart';
import '../../../transactions/domain/entities/transaction.dart';

part 'dashboard_controller.freezed.dart';
part 'dashboard_controller.g.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    required double monthlyTotal,
    DailyAllowance? dailyAllowance,
    Budget? overallMonthlyBudget,
    required List<CategoryBreakdown> categoryBreakdown,
    required List<BudgetProgress> budgetProgress,
    required List<Transaction> recentTransactions,
  }) = _DashboardState;
}

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<DashboardState> build() async {
    final sub = ref.watch(transactionRepositoryProvider).watchAllTransactions().listen((_) async {
      state = await AsyncValue.guard(() => _loadDashboard());
    });
    ref.onDispose(() => sub.cancel());

    return _loadDashboard();
  }

  Future<DashboardState> _loadDashboard() async {
    final now = DateTime.now();

    final analyticsEngine = ref.watch(analyticsEngineProvider);
    final budgetEngine = ref.watch(budgetEngineProvider);
    final budgetRepo = ref.watch(budgetRepositoryProvider);
    final txRepo = ref.watch(transactionRepositoryProvider);

    final monthlyTotal = await analyticsEngine.getMonthlyTotal(now.year, now.month);
    final dailyAllowance = await budgetEngine.calculateDailyAllowance(date: now);
    final overallBudget = await budgetRepo.getOverallBudget(now.month, now.year);
    final categoryBreakdown = await analyticsEngine.getCategoryBreakdown(now.year, now.month);

    final allTransactions = await txRepo.watchAllTransactions().first;
    final recentTransactions = allTransactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final limitedTransactions = recentTransactions.take(5).toList();

    return DashboardState(
      monthlyTotal: monthlyTotal,
      dailyAllowance: dailyAllowance,
      overallMonthlyBudget: overallBudget,
      categoryBreakdown: categoryBreakdown,
      budgetProgress: const [],
      recentTransactions: limitedTransactions,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboard());
  }
}
