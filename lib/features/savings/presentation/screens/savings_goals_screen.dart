import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../engines/savings/savings_engine_provider.dart';
import '../../../../routing/route_names.dart';
import '../widgets/savings_goal_card.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);
    final totalSavedAsync = ref.watch(savingsEngineProvider).getTotalSavings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.addSavingsGoal),
        backgroundColor: AppColors.darkGoldPrimary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Create Goal', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading goals: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.savings_outlined, size: 72, color: AppColors.darkGoldPrimary),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'No Savings Goals Yet',
                      style: AppTypography.heading2.copyWith(color: AppColors.darkTextPrimary),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'Start building your future by setting your first savings goal.',
                      style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    ElevatedButton.icon(
                      onPressed: () => context.pushNamed(RouteNames.addSavingsGoal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGoldPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Goal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ).animateEntrance(context),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder<int>(
                  future: totalSavedAsync,
                  builder: (context, snapshot) {
                    final totalPaise = snapshot.data ?? 0;
                    return Container(
                      margin: const EdgeInsets.all(AppSpacing.space4),
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Saved Across Goals',
                            style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          Text(
                            CurrencyFormatter.formatPaiseNoDecimals(totalPaise),
                            style: AppTypography.heading1.copyWith(
                              color: AppColors.darkGoldPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animateEntrance(context, index: 0);
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                        child: SavingsGoalCard(
                          goal: goal,
                          onTap: () => context.pushNamed(
                            RouteNames.savingsGoalDetail,
                            pathParameters: {'id': goal.id},
                          ),
                        ),
                      ).animateEntrance(context, index: index + 1);
                    },
                    childCount: goals.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
