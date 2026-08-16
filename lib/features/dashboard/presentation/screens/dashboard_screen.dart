import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/theme/app_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/layout/section_header.dart';
import '../../../../core/widgets/charts/progress_donut_chart.dart';
import '../../../../core/widgets/cards/status_tile.dart';
import '../../../../core/widgets/cards/transaction_row.dart';
import '../../../../features/categories/domain/entities/category.dart';
import '../../../../features/transactions/presentation/widgets/category_picker.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/notification_reader_service.dart';
import '../../../../services/notification_router.dart';
import '../../../../widgets/notification_transaction_sheet.dart';
import '../../../transactions/presentation/widgets/transfer_suggestion_banner.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/quick_add_fab.dart';
import '../widgets/recent_transactions.dart';

/// Floating action button location that floats above the floating pill bottom navigation bar.
class FloatingAboveBottomNavLocation extends FloatingActionButtonLocation {
  const FloatingAboveBottomNavLocation({
    this.bottomOffset = 88.0,
    this.rightOffset = 16.0,
  });

  final double bottomOffset;
  final double rightOffset;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        rightOffset;
    final double bottomPadding = scaffoldGeometry.minViewPadding.bottom;
    final double fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        bottomOffset -
        bottomPadding;
    return Offset(fabX, fabY);
  }
}

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
      floatingActionButtonLocation: const FloatingAboveBottomNavLocation(),
      floatingActionButton: QuickAddFab(
        onPressed: () {
          _showAddOptionsSheet(context);
        },
      ),
      body: SafeArea(
        child: state.when(
          data: (data) {
            return RefreshIndicator(
              onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  _buildTopBar(context, tokens),
                  const TransferSuggestionBanner(),
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
                    _buildBudgetDonut(context, tokens, data.overallMonthlyBudget!.amount, data.monthlyTotal),
                    const SizedBox(height: AppSpacing.space4),
                  ],

                  SectionHeader(
                    title: 'Recent Transactions',
                    actionLabel: 'See All',
                    onActionPressed: () => context.pushNamed(RouteNames.transactionList),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  RecentTransactionsWidget(transactions: data.recentTransactions),
                  const SizedBox(height: 120), // Padding for FAB + bottom nav bar
                ].animateStaggered(context),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
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
    // This strip shows account summaries. Currently placeholder — real wallet balance
    // would come from a dedicated accounts/wallet feature.
    return const SizedBox.shrink();
  }

  // Account pill helpers removed — using real data only, no hardcoded placeholders

  Widget _buildStatusTiles(BuildContext context, AppCustomTokens tokens, int healthScore, String insight) {
    final isHealthy = healthScore >= 80;
    final isCaution = healthScore >= 50 && healthScore < 80;
    final isCritical = healthScore < 0;

    final title = isHealthy
        ? 'Safe to spend'
        : isCaution
            ? 'Watch spending'
            : isCritical
                ? 'Critical Deficit'
                : 'Over Budget';

    final statusColor = isHealthy
        ? tokens.accentSavings
        : isCaution
            ? tokens.accentTransport
            : tokens.accentAlert;

    return Row(
      children: [
        Expanded(
          child: StatusTile(
            icon: isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            title: title,
            subtitle: 'Health: $healthScore',
            statusColor: statusColor,
            onTap: () => context.push('/insights'),
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: StatusTile(
            icon: Icons.lightbulb_outline,
            title: 'Insight',
            subtitle: insight,
            statusColor: AppColors.darkGoldPrimary,
            onTap: () => context.push('/insights'),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetDonut(BuildContext context, AppCustomTokens tokens, int budgetPaise, int spentPaise) {
    final remainingPaise = budgetPaise - spentPaise;
    final data = {
      'Spent': spentPaise / 100.0,
      'Remaining': remainingPaise > 0 ? (remainingPaise / 100.0) : 0.0,
    };
    final percentage = budgetPaise > 0 ? (spentPaise / budgetPaise) * 100 : 0.0;
    
    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.budgets),
      child: Container(
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
                    '${CurrencyFormatter.formatPaiseCompact(spentPaise)} of ${CurrencyFormatter.formatPaiseCompact(budgetPaise)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showAddOptionsSheet(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>() ?? AppCustomTokens.dark;

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
                  backgroundColor: tokens.accentTransport.withOpacity(0.2),
                  child: Icon(Icons.add, color: tokens.accentTransport),
                ),
                title: Text(
                  'One-Time Transaction',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Record a single expense or income'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.pushNamed(RouteNames.addTransaction);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: tokens.accentBills.withOpacity(0.2),
                  child: Icon(Icons.repeat, color: tokens.accentBills),
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
