import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/widgets/layout/empty_state.dart';
import '../../../../engines/savings/savings_engine_provider.dart';
import '../../../../routing/route_names.dart';
import '../widgets/savings_goal_card.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);
    final totalSavedAsync = ref.watch(savingsEngineProvider).totalSaved();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.addSavingsGoal),
        child: const Icon(Icons.add),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return const EmptyState(
              title: 'No Savings Goals',
              subtitle: 'Set a goal and start tracking your savings journey.',
              animationPath: 'assets/animations/empty.json',
            );
          }
          
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder<double>(
                  future: totalSavedAsync,
                  builder: (context, snapshot) {
                    final total = snapshot.data ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Total Saved', style: context.textTheme.titleMedium),
                          Text(total.toCurrency(), style: context.textTheme.headlineLarge?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SavingsGoalCard(
                          goal: goal,
                          onTap: () => context.pushNamed(
                            RouteNames.savingsGoalDetail,
                            pathParameters: {'id': goal.id},
                          ),
                        ),
                      );
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
