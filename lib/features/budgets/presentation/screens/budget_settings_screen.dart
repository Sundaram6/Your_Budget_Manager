import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../database/app_database.dart';
import '../../../../engines/analytics/analytics_engine_provider.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';

import '../../../../engines/budget/models/budget_progress.dart';

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
  BudgetProgress? _budgetProgress;

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
    final budgetEngine = ref.read(budgetEngineProvider);

    final budget = await budgetRepo.getOverallBudget(now.month, now.year);
    final progress = await budgetEngine.calculateBudgetProgress(date: now);

    if (mounted) {
      setState(() {
        _currentBudget = budget;
        _budgetProgress = progress;
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
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: const Text('Are you sure you want to remove your overall monthly budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.darkExpense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final now = DateTime.now();
    final budgetRepo = ref.read(budgetRepositoryProvider);

    try {
      await budgetRepo.deleteBudget(_currentBudget!);
      ref.invalidate(dashboardControllerProvider);
      _amountController.clear();
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
    final spentPaise = _budgetProgress?.spent ?? 0;
    final committedRecurring = _budgetProgress?.committedRecurring ?? 0;
    final committedSavings = _budgetProgress?.committedSavings ?? 0;
    final totalCommitted = _budgetProgress?.totalCommitted ?? (spentPaise + committedRecurring + committedSavings);
    final remainingPaise = _budgetProgress?.remaining ?? (budgetPaise - spentPaise);
    final isOverBudget = _budgetProgress?.isOverBudget ?? (totalCommitted > budgetPaise);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Monthly Budget Settings'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        border: Border.all(
                          color: isOverBudget
                              ? AppColors.darkExpense.withValues(alpha: 0.5)
                              : AppColors.darkGoldPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${DateFormat('MMMM yyyy').format(now)} Budget',
                                  style: AppTypography.heading3.copyWith(
                                    color: isOverBudget ? AppColors.darkExpense : AppColors.darkGoldPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurface3,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${CurrencyFormatter.formatPaise(budgetPaise)} / mo',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          LinearProgressIndicator(
                            value: budgetPaise > 0 ? (totalCommitted / budgetPaise).clamp(0.0, 1.0) : 0.0,
                            backgroundColor: AppColors.darkSurface3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOverBudget ? AppColors.darkExpense : AppColors.darkGoldPrimary,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          // Committed breakdown
                          Wrap(
                            spacing: AppSpacing.space2,
                            runSpacing: AppSpacing.space1,
                            children: [
                              Text(
                                'Spent: ${CurrencyFormatter.formatPaise(spentPaise)}',
                                style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                              ),
                              if (committedRecurring > 0) ...[
                                Text('•', style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary)),
                                Text(
                                  'Recurring: ${CurrencyFormatter.formatPaise(committedRecurring)}',
                                  style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                                ),
                              ],
                              if (committedSavings > 0) ...[
                                Text('•', style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary)),
                                Text(
                                  'Savings: ${CurrencyFormatter.formatPaise(committedSavings)}',
                                  style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Committed',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space2),
                              Flexible(
                                child: Text(
                                  CurrencyFormatter.formatPaise(totalCommitted),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isOverBudget ? AppColors.darkExpense : AppColors.darkIncome).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (isOverBudget ? AppColors.darkExpense : AppColors.darkIncome).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isOverBudget ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                  size: 14,
                                  color: isOverBudget ? AppColors.darkExpense : AppColors.darkIncome,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    isOverBudget
                                        ? 'Over-committed by ${CurrencyFormatter.formatPaise(-remainingPaise)}'
                                        : 'Remaining: ${CurrencyFormatter.formatPaise(remainingPaise)}',
                                    style: AppTypography.caption.copyWith(
                                      color: isOverBudget ? AppColors.darkExpense : AppColors.darkIncome,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isOverBudget) ...[
                            const SizedBox(height: AppSpacing.space3),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.space3),
                              decoration: BoxDecoration(
                                color: AppColors.darkExpense.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.darkExpense.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: AppColors.darkExpense, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '🚨 Survival Mode Active',
                                          style: TextStyle(
                                            color: AppColors.darkExpense,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "You've exceeded your budget by ${CurrencyFormatter.formatPaise(-remainingPaise)}. Freeze non-essential spending for the remaining ${max(1, DateTime(now.year, now.month + 1, 0).day - now.day + 1)} days.",
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.darkTextSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animateEntrance(context, index: 0),
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
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                        const SizedBox(height: AppSpacing.space6),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
