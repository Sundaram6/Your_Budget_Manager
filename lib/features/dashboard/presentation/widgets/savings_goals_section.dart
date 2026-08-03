import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../engines/savings/savings_engine_provider.dart';

class SavingsGoalsSection extends ConsumerWidget {
  const SavingsGoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsStreamProvider);

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkSurface3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Savings Goals',
                style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
              ),
              TextButton(
                onPressed: () => context.push('/savings-goals'),
                child: Text(
                  'See All',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.darkGoldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          goalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text(
              'Failed to load goals: $err',
              style: AppTypography.caption.copyWith(color: AppColors.darkExpense),
            ),
            data: (goals) {
              final activeGoals = goals.where((g) => g.status == 'active').take(3).toList();

              if (activeGoals.isEmpty) {
                return Column(
                  children: [
                    Text(
                      'No savings goals yet. Start building your future.',
                      style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/savings-goals/add'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create Goal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGoldPrimary,
                        side: const BorderSide(color: AppColors.darkGoldPrimary),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: activeGoals.map((goal) {
                  final targetRupees = goal.targetAmount / 100;
                  final currentRupees = goal.currentAmount / 100;
                  final ratio = targetRupees > 0 ? (currentRupees / targetRupees).clamp(0.0, 1.0) : 0.0;
                  final pct = (ratio * 100).round();

                  return InkWell(
                    onTap: () => context.push('/savings-goals/${goal.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: CircularProgressIndicator(
                                  value: ratio,
                                  backgroundColor: AppColors.darkSurface3,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkIncome),
                                  strokeWidth: 4,
                                ),
                              ),
                              Icon(
                                _getGoalIcon(goal.iconName),
                                size: 20,
                                color: AppColors.darkGoldPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${currencyFormat.format(currentRupees)} / ${currencyFormat.format(targetRupees)}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.darkTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$pct%',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.darkIncome,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(String iconName) {
    switch (iconName) {
      case 'emergency':
        return Icons.healing;
      case 'phone':
        return Icons.phone_iphone;
      case 'car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'flight':
        return Icons.flight_takeoff;
      case 'school':
        return Icons.school;
      default:
        return Icons.savings;
    }
  }
}
