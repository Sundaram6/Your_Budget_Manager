import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/layout/section_header.dart';
import '../../../../database/database_helper.dart';
import '../../../../engines/savings/savings_engine_provider.dart';
import '../../../../models/recurring_transaction.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/notification_reader_service.dart';
import '../../../../services/notification_router.dart';
import '../../../../widgets/notification_transaction_sheet.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/daily_allowance_card.dart';
import '../widgets/quick_add_fab.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/savings_goals_section.dart';
import '../widgets/total_spend_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    NotificationReaderService.instance.initialize();
    NotificationRouter.instance.pendingNotification.addListener(_onPendingNotification);

    // Check if there is an unhandled pending notification on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onPendingNotification();
    });
  }

  @override
  void dispose() {
    NotificationRouter.instance.pendingNotification.removeListener(_onPendingNotification);
    super.dispose();
  }

  void _onPendingNotification() {
    final data = NotificationRouter.instance.pendingNotification.value;
    if (data != null && mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => NotificationTransactionSheet(data: data),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.repeat, color: Color(0xFFD4AF37)),
            tooltip: 'Recurring Transactions',
            onPressed: () {
              context.pushNamed(RouteNames.recurring);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFFD4AF37)),
            tooltip: 'Notification Settings',
            onPressed: () {
              context.push('/notification-settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
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
                // Recurring Transactions Due Today Summary Card
                FutureBuilder<List<RecurringTransactionModel>>(
                  future: DatabaseHelper.instance.getDueRecurringTransactions(todayStr),
                  builder: (context, snapshot) {
                    final dueCount = snapshot.data?.length ?? 0;
                    if (dueCount == 0) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.space4),
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.repeat, color: Color(0xFFD4AF37), size: 28),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$dueCount Recurring Due Today',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tap to view and manage recurring transactions',
                                  style: TextStyle(
                                    color: AppColors.darkTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pushNamed(RouteNames.recurring),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

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
                  title: 'Recurring Payments',
                  actionLabel: 'View All',
                  onActionPressed: () => context.push('/recurring'),
                ),
                const SizedBox(height: AppSpacing.space2),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.repeat, color: Color(0xFFD4AF37), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bills & Subscriptions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Rent, EMI, Netflix, Mobile Recharge...',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => context.push('/create-recurring'),
                        child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
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
          _showAddOptionsSheet(context);
        },
      ),
    );
  }

  void _showAddOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171A23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFFD4AF37)),
                ),
                title: const Text(
                  'One-Time Transaction',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Record a single expense or income',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.pushNamed('addTransaction');
                },
              ),
              const Divider(color: Color(0xFF2A2A2A)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.repeat, color: Colors.purpleAccent),
                ),
                title: const Text(
                  'Recurring Payment',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Rent, EMI, Netflix, SIP, Recharge...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/create-recurring');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
