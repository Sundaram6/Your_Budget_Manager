import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/layout/section_header.dart';
import '../../../../core/widgets/charts/progress_donut_chart.dart';
import '../../../../core/widgets/cards/status_tile.dart';
import '../../../../core/widgets/cards/transaction_row.dart';
import '../../../../database/database_helper.dart';
import '../../../../models/recurring_transaction.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/notification_reader_service.dart';
import '../../../../services/notification_router.dart';
import '../../../../widgets/notification_transaction_sheet.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/quick_add_fab.dart';

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
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;
    
    return Scaffold(
      body: SafeArea(
        child: state.when(
          data: (data) {
            return RefreshIndicator(
              onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  _buildTopBar(context, tokens),
                  const SizedBox(height: AppSpacing.space4),
                  HeroBalanceCard(totalBalance: data.monthlyTotal), // TODO: Use real total balance
                  const SizedBox(height: AppSpacing.space4),
                  _buildAccountsStrip(context, tokens),
                  const SizedBox(height: AppSpacing.space4),
                  _buildStatusTiles(context, tokens, data.healthScore, data.insights.isNotEmpty ? data.insights.first.title : 'No new insights'),
                  const SizedBox(height: AppSpacing.space4),
                  
                  if (data.overallMonthlyBudget != null) ...[
                    const SectionHeader(title: 'Budget Progress'),
                    const SizedBox(height: AppSpacing.space3),
                    _buildBudgetDonut(context, tokens, data.overallMonthlyBudget!.amount / 100, data.monthlyTotal),
                    const SizedBox(height: AppSpacing.space4),
                  ],

                  SectionHeader(
                    title: 'Recent Transactions',
                    actionLabel: 'See All',
                    onActionPressed: () => context.pushNamed('transactionList'),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _buildRecentTransactions(context, data.recentTransactions),
                  const SizedBox(height: 80), // Padding for FAB
                ].animate(interval: 50.ms).fade(duration: 300.ms).slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: QuickAddFab(
        onPressed: () {
          _showAddOptionsSheet(context);
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppCustomTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.pushNamed('settings'),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: tokens.accentTransport.withOpacity(0.2),
            child: Icon(Icons.person, color: tokens.accentTransport),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.accentSavings.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 14, color: tokens.accentSavings),
              const SizedBox(width: 4),
              Text(
                'Local Only',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.accentSavings,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsStrip(BuildContext context, AppCustomTokens tokens) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildAccountPill(context, tokens, 'Main Account', 12450.00, true),
          const SizedBox(width: 12),
          _buildAccountPill(context, tokens, 'Cash Wallet', 450.00, false),
          const SizedBox(width: 12),
          _buildAddAccountPill(context, tokens),
        ],
      ),
    );
  }

  Widget _buildAccountPill(BuildContext context, AppCustomTokens tokens, String name, double balance, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius / 2),
        border: Border.all(
          color: active ? tokens.heroSurfaceColor.withOpacity(0.2) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountPill(BuildContext context, AppCustomTokens tokens) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius / 2),
      ),
      child: Center(
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildStatusTiles(BuildContext context, AppCustomTokens tokens, int healthScore, String insight) {
    final isHealthy = healthScore > 70;
    return Row(
      children: [
        Expanded(
          child: StatusTile(
            icon: isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            title: isHealthy ? 'Safe to spend' : 'Watch spending',
            subtitle: 'Health: $healthScore',
            statusColor: isHealthy ? tokens.accentSavings : tokens.accentAlert,
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: StatusTile(
            icon: Icons.lightbulb_outline,
            title: 'Insight',
            subtitle: insight,
            statusColor: tokens.accentBills,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetDonut(BuildContext context, AppCustomTokens tokens, double budget, double spent) {
    final remaining = budget - spent;
    final data = {
      'Spent': spent,
      'Remaining': remaining > 0 ? remaining : 0.0,
    };
    final percentage = (spent / budget) * 100;
    
    return Container(
      padding: EdgeInsets.all(tokens.gridUnit * 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: ProgressDonutChart(
              data: data,
              colors: [
                percentage > 90 ? tokens.accentAlert : tokens.accentTransport,
                Theme.of(context).scaffoldBackgroundColor, // Empty part of donut
              ],
              strokeWidth: 16,
              centerRadius: 40,
              centerWidget: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Budget',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${spent.toStringAsFixed(0)} of \$${budget.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions yet.'));
    }
    
    return Column(
      children: transactions.map((tx) {
        // Need to parse category color from tx.category if possible, 
        // for now just use a fallback or determine by isIncome
        final color = tx.isIncome 
            ? Theme.of(context).extension<AppCustomTokens>()!.accentSavings 
            : Theme.of(context).extension<AppCustomTokens>()!.accentShopping;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TransactionRow(
            merchantName: tx.title,
            category: tx.category,
            amount: tx.amount,
            date: tx.date,
            isIncome: tx.isIncome,
            categoryColor: color,
            onTap: () {
              // Navigate to details if needed
            },
          ),
        );
      }).toList(),
    );
  }

  void _showAddOptionsSheet(BuildContext context) {
    // Keep original logic or style to match v2
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).extension<AppCustomTokens>()!.accentTransport.withOpacity(0.2),
                  child: Icon(Icons.add, color: Theme.of(context).extension<AppCustomTokens>()!.accentTransport),
                ),
                title: Text(
                  'One-Time Transaction',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Record a single expense or income'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.pushNamed('addTransaction');
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).extension<AppCustomTokens>()!.accentBills.withOpacity(0.2),
                  child: Icon(Icons.repeat, color: Theme.of(context).extension<AppCustomTokens>()!.accentBills),
                ),
                title: Text(
                  'Recurring Payment',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Rent, EMI, Netflix, SIP, Recharge...'),
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
