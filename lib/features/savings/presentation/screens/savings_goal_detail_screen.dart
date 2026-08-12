import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../database/app_database.dart';
import '../../../../engines/savings/savings_engine_provider.dart';

class SavingsGoalDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const SavingsGoalDetailScreen({super.key, required this.id});

  @override
  ConsumerState<SavingsGoalDetailScreen> createState() => _SavingsGoalDetailScreenState();
}

class _SavingsGoalDetailScreenState extends ConsumerState<SavingsGoalDetailScreen> {
  final _depositController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _contributeAmount(int amountPaise) async {
    if (amountPaise <= 0) return;
    setState(() => _isLoading = true);
    final engine = ref.read(savingsEngineProvider);

    try {
      await engine.contributeToGoal(widget.id, amountPaise);
      _depositController.clear();
      if (mounted) {
        final formatted = CurrencyFormatter.formatPaiseNoDecimals(amountPaise);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $formatted to goal!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to contribute: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGoal(SavingsGoal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal?'),
        content: Text('Are you sure you want to delete "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.darkExpense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final engine = ref.read(savingsEngineProvider);
    try {
      await engine.deleteGoal(goal.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Goal "${goal.name}" deleted.')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(savingsGoalStreamProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
      ),
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading goal: $e')),
        data: (goal) {
          if (goal == null) {
            return const Center(child: Text('Goal not found'));
          }

          final currentPaise = goal.currentAmount;
          final targetPaise = goal.targetAmount;
          final remainingPaise = max(0, targetPaise - currentPaise);
          final ratio = targetPaise > 0 ? (currentPaise / targetPaise).clamp(0.0, 1.0) : 0.0;
          final pct = (ratio * 100).round();

          int? daysLeft;
          if (goal.deadline != null) {
            final now = DateTime.now();
            final deadlineDate = DateTime.fromMillisecondsSinceEpoch(goal.deadline!);
            daysLeft = deadlineDate.difference(now).inDays;
          }

          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  children: [
                    // Large Progress Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space6),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: ratio,
                                  backgroundColor: AppColors.darkSurface3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    goal.status == 'completed' ? Colors.green : AppColors.darkGoldPrimary,
                                  ),
                                  strokeWidth: 12,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$pct%',
                                    style: AppTypography.heading1.copyWith(
                                      color: AppColors.darkGoldPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    goal.status.toUpperCase(),
                                    style: AppTypography.caption.copyWith(
                                      color: goal.status == 'completed' ? Colors.green : AppColors.darkTextSecondary,
                                      fontSize: 10,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            goal.name,
                            style: AppTypography.heading2.copyWith(color: AppColors.darkTextPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Text(
                            '${CurrencyFormatter.formatPaiseNoDecimals(currentPaise)} saved of ${CurrencyFormatter.formatPaiseNoDecimals(targetPaise)}',
                            style: AppTypography.heading3.copyWith(color: AppColors.darkGoldPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          Text(
                            'Remaining: ${CurrencyFormatter.formatPaiseNoDecimals(remainingPaise)}',
                            style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                          ),
                          if (daysLeft != null) ...[
                            const SizedBox(height: AppSpacing.space3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (daysLeft < 7 ? AppColors.darkExpense : AppColors.darkIncome).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                daysLeft >= 0 ? '$daysLeft days left' : 'Deadline passed',
                                style: AppTypography.caption.copyWith(
                                  color: daysLeft < 7 ? AppColors.darkExpense : AppColors.darkIncome,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // Quick Deposit Chips
                    Text(
                      'Quick Deposit',
                      style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Row(
                      children: [
                        Expanded(
                          child: ActionChip(
                            backgroundColor: AppColors.darkSurface2,
                            side: const BorderSide(color: AppColors.darkGoldPrimary),
                            label: const Text('+₹500', style: TextStyle(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold)),
                            onPressed: () => _contributeAmount(50000),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ActionChip(
                            backgroundColor: AppColors.darkSurface2,
                            side: const BorderSide(color: AppColors.darkGoldPrimary),
                            label: const Text('+₹1,000', style: TextStyle(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold)),
                            onPressed: () => _contributeAmount(100000),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ActionChip(
                            backgroundColor: AppColors.darkSurface2,
                            side: const BorderSide(color: AppColors.darkGoldPrimary),
                            label: const Text('+₹5,000', style: TextStyle(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold)),
                            onPressed: () => _contributeAmount(500000),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // Custom Contribution Form
                    Text(
                      'Custom Contribution',
                      style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _depositController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.darkTextPrimary),
                            decoration: InputDecoration(
                              labelText: 'Deposit Amount (₹)',
                              prefixText: '₹ ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGoldPrimary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            final paise = CurrencyFormatter.parseRupeesToPaise(_depositController.text) ?? 0;
                            if (paise > 0) {
                              _contributeAmount(paise);
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Contribute', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // Delete Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkExpense,
                        side: const BorderSide(color: AppColors.darkExpense),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _deleteGoal(goal),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Goal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
