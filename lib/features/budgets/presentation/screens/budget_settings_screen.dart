import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../database/app_database.dart';
import '../../../../engines/analytics/analytics_engine_provider.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';

class BudgetSettingsScreen extends ConsumerStatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  ConsumerState<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends ConsumerState<BudgetSettingsScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Budget? _currentBudget;
  int _currentMonthSpentPaise = 0;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();

    final budgetRepo = ref.read(budgetRepositoryProvider);
    final analyticsEngine = ref.read(analyticsEngineProvider);

    final budget = await budgetRepo.getOverallBudget(now.month, now.year);
    final spentPaise = await analyticsEngine.getMonthlyTotal(now.year, now.month);

    if (mounted) {
      setState(() {
        _currentBudget = budget;
        _currentMonthSpentPaise = spentPaise;
        if (budget != null) {
          final rupees = (budget.amount / 100).toStringAsFixed(0);
          _amountController.text = rupees;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final amountPaise = CurrencyFormatter.parseRupeesToPaise(_amountController.text) ?? 0;
    if (amountPaise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than ₹0.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final now = DateTime.now();
    final budgetEngine = ref.read(budgetEngineProvider);

    try {
      await budgetEngine.setMonthlyBudget(
        amountPaise: amountPaise,
        month: now.month,
        year: now.year,
      );

      // Invalidate dashboard to reload instantly
      ref.invalidate(dashboardControllerProvider);
      await _loadBudgetData();

      if (mounted) {
        final formatted = CurrencyFormatter.formatPaiseNoDecimals(amountPaise);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Monthly budget set to $formatted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save budget: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBudget() async {
    if (_currentBudget == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Monthly Budget?'),
        content: const Text('Are you sure you want to remove your overall monthly budget for this month?'),
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
    final budgetRepo = ref.read(budgetRepositoryProvider);

    try {
      await budgetRepo.deleteBudget(_currentBudget!);
      _amountController.clear();

      ref.invalidate(dashboardControllerProvider);
      await _loadBudgetData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monthly budget deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete budget: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final budgetPaise = _currentBudget?.amount ?? 0;
    final remainingPaise = max(0, budgetPaise - _currentMonthSpentPaise);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              children: [
                // Current Budget Status Summary
                if (_currentBudget != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Budget (${now.month}/${now.year})',
                          style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          CurrencyFormatter.formatPaiseNoDecimals(budgetPaise),
                          style: AppTypography.heading2.copyWith(color: AppColors.darkGoldPrimary),
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ${CurrencyFormatter.formatPaise(_currentMonthSpentPaise)}',
                              style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                            ),
                            Text(
                              'Remaining: ${CurrencyFormatter.formatPaise(remainingPaise)}',
                              style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                ],

                // Budget Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentBudget != null ? 'Edit Monthly Budget' : 'Set Monthly Budget',
                        style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        'Set a total monthly spending limit in Rupees. Your daily allowance will auto-calculate based on remaining budget.',
                        style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                      ),
                      const SizedBox(height: AppSpacing.space4),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Monthly Budget Amount',
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(color: AppColors.darkGoldPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.darkGoldPrimary, width: 2),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter budget amount';
                          final paise = CurrencyFormatter.parseRupeesToPaise(val);
                          if (paise == null || paise <= 0) return 'Enter a valid amount > 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.space6),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGoldPrimary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveBudget,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            _currentBudget != null ? 'Update Budget' : 'Save Budget',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      if (_currentBudget != null) ...[
                        const SizedBox(height: AppSpacing.space4),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkExpense,
                              side: const BorderSide(color: AppColors.darkExpense),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _deleteBudget,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
