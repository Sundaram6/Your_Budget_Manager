import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../engines/savings/savings_engine_provider.dart';

class AddSavingsGoalScreen extends ConsumerStatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  ConsumerState<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends ConsumerState<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _autoDeductAmountController = TextEditingController();
  final _incomeController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _linkToBudget = true;
  bool _autoDeduct = false;
  bool _isLoading = false;

  ({int needs, int wants, int savings})? _ruleBreakdown;

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _autoDeductAmountController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _calculate50_30_20(String val) {
    final rupees = double.tryParse(val.trim()) ?? 0.0;
    final incomePaise = (rupees * 100).round();
    final engine = ref.read(savingsEngineProvider);
    setState(() {
      _ruleBreakdown = engine.calculate50_30_20(incomePaise);
    });
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final targetRupees = double.tryParse(_targetAmountController.text.trim()) ?? 0.0;
    if (targetRupees <= 0) return;

    final targetPaise = (targetRupees * 100).round();

    int? autoDeductPaise;
    if (_autoDeduct) {
      final autoRupees = double.tryParse(_autoDeductAmountController.text.trim()) ?? 0.0;
      if (autoRupees > 0) {
        autoDeductPaise = (autoRupees * 100).round();
      }
    }

    setState(() => _isLoading = true);

    try {
      String? budgetId;
      if (_linkToBudget) {
        final now = DateTime.now();
        final budgetRepo = ref.read(budgetRepositoryProvider);
        final currentBudget = await budgetRepo.getOverallBudget(now.month, now.year);
        budgetId = currentBudget?.id;
      }

      final savingsEngine = ref.read(savingsEngineProvider);
      await savingsEngine.createGoal(
        name: name,
        targetAmountPaise: targetPaise,
        deadline: _selectedDeadline,
        linkedBudgetId: budgetId,
        autoDeduct: _autoDeduct,
        autoDeductAmountPaise: autoDeductPaise,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Savings Goal "$name" created!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create goal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Savings Goal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.darkTextPrimary),
                    decoration: InputDecoration(
                      labelText: 'Goal Name',
                      hintText: 'e.g. Emergency Fund, iPhone 16',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter goal name';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  TextFormField(
                    controller: _targetAmountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Target Amount (₹)',
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(color: AppColors.darkGoldPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Enter target amount';
                      final d = double.tryParse(val.trim());
                      if (d == null || d <= 0) return 'Enter a valid amount > ₹0';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Optional Deadline Picker
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.darkSurface3),
                    ),
                    tileColor: AppColors.darkSurface2,
                    leading: const Icon(Icons.calendar_today, color: AppColors.darkGoldPrimary),
                    title: Text(
                      _selectedDeadline != null
                          ? 'Deadline: ${DateFormat('dd MMM yyyy').format(_selectedDeadline!)}'
                          : 'Set Target Deadline (Optional)',
                      style: AppTypography.caption.copyWith(color: AppColors.darkTextPrimary),
                    ),
                    trailing: _selectedDeadline != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _selectedDeadline = null),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _pickDeadline,
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Link to current month budget toggle
                  SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.darkSurface3),
                    ),
                    tileColor: AppColors.darkSurface2,
                    activeColor: AppColors.darkGoldPrimary,
                    title: const Text('Link to Current Month Budget'),
                    subtitle: const Text('Goal contributions will be tracked in monthly budget allocation'),
                    value: _linkToBudget,
                    onChanged: (val) => setState(() => _linkToBudget = val),
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // Auto-deduct toggle
                  SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.darkSurface3),
                    ),
                    tileColor: AppColors.darkSurface2,
                    activeColor: AppColors.darkGoldPrimary,
                    title: const Text('Auto-Save Monthly'),
                    subtitle: const Text('Auto-deduct a fixed amount on the 1st of each month'),
                    value: _autoDeduct,
                    onChanged: (val) => setState(() => _autoDeduct = val),
                  ),

                  if (_autoDeduct) ...[
                    const SizedBox(height: AppSpacing.space3),
                    TextFormField(
                      controller: _autoDeductAmountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.darkTextPrimary),
                      decoration: InputDecoration(
                        labelText: 'Monthly Auto-Deduct Amount (₹)',
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(color: AppColors.darkGoldPrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        if (!_autoDeduct) return null;
                        if (val == null || val.trim().isEmpty) return 'Enter monthly auto-deduct amount';
                        final d = double.tryParse(val.trim());
                        if (d == null || d <= 0) return 'Enter a valid amount > ₹0';
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: AppSpacing.space6),

                  // 50/30/20 Rule AI Financial Tip Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.darkGoldPrimary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '50/30/20 Rule Calculator',
                              style: TextStyle(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your monthly income to calculate recommended savings.',
                          style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _incomeController,
                          keyboardType: TextInputType.number,
                          onChanged: _calculate50_30_20,
                          style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Enter Monthly Income (₹)',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        if (_ruleBreakdown != null && _ruleBreakdown!.savings > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface3,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('50% Needs:', style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary)),
                                    Text(currencyFormat.format(_ruleBreakdown!.needs / 100), style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('30% Wants:', style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary)),
                                    Text(currencyFormat.format(_ruleBreakdown!.wants / 100), style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('20% Savings (Recommended):', style: AppTypography.caption.copyWith(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold)),
                                    Text(currencyFormat.format(_ruleBreakdown!.savings / 100), style: AppTypography.caption.copyWith(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.space6),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGoldPrimary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveGoal,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Create Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
