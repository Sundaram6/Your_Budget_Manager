import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../controllers/dashboard_controller.dart';
import 'widgets/total_spend_card.dart';
import 'widgets/daily_allowance_card.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/budget_summary.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/quick_add_fab.dart';
import '../../../../core/widgets/layout/section_header.dart';
import '../../../../core/theme/app_spacing.dart';

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
              // Navigate to settings (if any)
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
              
              const SectionHeader(title: 'Budgets'),
              const SizedBox(height: AppSpacing.space3),
              BudgetSummaryWidget(budgets: data.budgetProgress),
              const SizedBox(height: AppSpacing.space4),
              
              const SectionHeader(title: 'Recent Transactions'),
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
          // Navigate to add transaction
        },
      ),
    );
  }
}
