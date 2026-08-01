import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/layout/section_header.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/budget_summary.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/daily_allowance_card.dart';
import '../widgets/quick_add_fab.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/total_spend_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

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
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space4),
            children: [
              TotalSpendCard(totalSpend: data.monthlyTotal),
              const SizedBox(height: AppSpacing.space4),
              
              DailyAllowanceCard(allowance: data.dailyAllowance),
              const SizedBox(height: AppSpacing.space4),
              
              const SectionHeader(title: 'Category Breakdown'),
              const SizedBox(height: AppSpacing.space3),
              CategoryBreakdownWidget(breakdowns: data.categoryBreakdown),
              const SizedBox(height: AppSpacing.space4),
              
              SectionHeader(
                title: 'Savings Goals',
                actionLabel: 'See All',
                onActionPressed: () => context.pushNamed(RouteNames.savingsGoals),
              ),
              const SizedBox(height: AppSpacing.space3),
              ListTile(
                leading: const Icon(Icons.savings),
                title: const Text('Savings Goals'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.savingsGoals),
              ),
              const SizedBox(height: AppSpacing.space4),

              SectionHeader(
                title: 'Budgets',
                actionLabel: 'See All',
                onActionPressed: () => context.pushNamed('budgets'),
              ),
              const SizedBox(height: AppSpacing.space3),
              BudgetSummaryWidget(budgets: data.budgetProgress),
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
        ),
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
