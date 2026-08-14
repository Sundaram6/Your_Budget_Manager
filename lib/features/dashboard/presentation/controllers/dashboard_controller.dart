import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../database/app_database.dart' hide Transaction;

import '../../../../engines/analytics/analytics_engine_provider.dart';
import '../../../../engines/analytics/models/analytics_models.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../../../engines/budget/models/budget_progress.dart';
import '../../../../engines/budget/models/daily_allowance.dart';
import '../../../../engines/intelligence/intelligence_engine_provider.dart';
import '../../../../engines/intelligence/models/ai_insight.dart';
import '../../../transactions/domain/entities/transaction.dart';

part 'dashboard_controller.freezed.dart';
part 'dashboard_controller.g.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required int monthlyTotal, // Integer paise
    DailyAllowance? dailyAllowance,
    Budget? overallMonthlyBudget,
    required List<CategoryBreakdown> categoryBreakdown,
    required List<BudgetProgress> budgetProgress,
    required List<Transaction> recentTransactions,
    @Default([]) List<AiInsight> insights,
    @Default(100) int healthScore,
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
    final intelligenceEngine = ref.watch(intelligenceEngineProvider);

    final monthlyTotal = await analyticsEngine.getMonthlyTotal(now.year, now.month);
    final dailyAllowance = await budgetEngine.calculateDailyAllowance(date: now);
    final overallBudget = await budgetRepo.getOverallBudget(now.month, now.year);
    final categoryBreakdown = await analyticsEngine.getCategoryBreakdown(now.year, now.month);

    final insights = await intelligenceEngine.generateInsights();
    final healthScore = await intelligenceEngine.calculateBudgetHealthScore();

    final allTransactions = await txRepo.watchAllTransactions().first;
    final recentTransactions = allTransactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final limitedTransactions = recentTransactions.take(5).toList();

    final progress = await budgetEngine.calculateBudgetProgress(date: now);
    final budgetProgressList = progress != null ? [progress] : <BudgetProgress>[];

    return DashboardState(
      monthlyTotal: monthlyTotal,
      dailyAllowance: dailyAllowance,
      overallMonthlyBudget: overallBudget,
      categoryBreakdown: categoryBreakdown,
      budgetProgress: budgetProgressList,
      recentTransactions: limitedTransactions,
      insights: insights,
      healthScore: healthScore,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboard());
  }
}
