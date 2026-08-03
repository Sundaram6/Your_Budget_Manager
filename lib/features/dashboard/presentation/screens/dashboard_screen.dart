import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/layout/section_header.dart';
import '../../../../engines/savings/savings_engine_provider.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/daily_allowance_card.dart';
import '../widgets/quick_add_fab.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/savings_goals_section.dart';
import '../widgets/total_spend_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.pushNamed('settings');
            },
          ),
        ],
      ),
      body: state.when(
        data: (data) {
          final budget = data.overallMonthlyBudget;
          double savingsAllocationsRupees = 0.0;
          if (budget != null && goalsAsync.hasValue) {
            final linkedGoals = goalsAsync.value!.where((g) => g.budgetId == budget.id);
            for (final g in linkedGoals) {
              if (g.autoDeduct && g.autoDeductAmount != null && g.autoDeductAmount! > 0) {
                savingsAllocationsRupees += (g.autoDeductAmount! / 100);
              }
            }
          }

          final topInsight = data.insights.isNotEmpty ? data.insights.first : null;

          return RefreshIndicator(
            onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              children: [
                TotalSpendCard(totalSpend: data.monthlyTotal),
                const SizedBox(height: AppSpacing.space4),

                if (budget != null) ...[
                  BudgetProgressCard(
                    budget: budget,
                    spentAmount: data.monthlyTotal,
                    savingsAllocationsRupees: savingsAllocationsRupees,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171A23),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF5D395).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: Color(0xFFF5D395)),
                            SizedBox(width: AppSpacing.space2),
                            Text(
                              'Set Monthly Budget',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        const Text(
                          'Set your monthly budget to track spending & daily allowance',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5D395),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () => context.pushNamed('budgets'),
                            icon: const Icon(Icons.add),
                            label: const Text('Set Monthly Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],

                if (data.dailyAllowance != null) ...[
                  DailyAllowanceCard(allowance: data.dailyAllowance!),
                  const SizedBox(height: AppSpacing.space4),
                ],

                AiInsightsCard(
                  healthScore: data.healthScore,
                  topInsight: topInsight,
                ),
                const SizedBox(height: AppSpacing.space4),

                const SectionHeader(title: 'Category Breakdown'),
                const SizedBox(height: AppSpacing.space3),
                CategoryBreakdownWidget(breakdowns: data.categoryBreakdown),
                const SizedBox(height: AppSpacing.space4),

                const SavingsGoalsSection(),
                const SizedBox(height: AppSpacing.space4),

                SectionHeader(
                  title: 'Recent Transactions',
                  actionLabel: 'See All',
                  onActionPressed: () => context.pushNamed('transactionList'),
                ),
                const SizedBox(height: AppSpacing.space3),
                RecentTransactionsWidget(transactions: data.recentTransactions),
              ].animate(interval: 50.ms).fade(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: QuickAddFab(
        onPressed: () {
          context.pushNamed('addTransaction');
        },
      ),
    );
  }
}
