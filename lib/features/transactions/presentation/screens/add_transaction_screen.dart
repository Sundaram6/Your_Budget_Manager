import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/inputs/numeric_keypad.dart';
import '../controllers/add_transaction_controller.dart';
import '../widgets/category_picker.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _amountStr = '0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialAmt = ref.read(addTransactionControllerProvider).amount;
      if (initialAmt > 0) {
        setState(() {
          _amountStr = initialAmt.toString().replaceAll(RegExp(r'\.0$'), '');
        });
      }
    });
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_amountStr == '0' && key != '.') {
        _amountStr = key;
      } else {
        if (key == '.' && _amountStr.contains('.')) return; // prevent multiple dots
        
        // Prevent more than 2 decimal places
        if (_amountStr.contains('.')) {
          final parts = _amountStr.split('.');
          if (parts.length > 1 && parts[1].length >= 2) return;
        }

        _amountStr += key;
      }
    });
    _updateControllerAmount();
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
    _updateControllerAmount();
  }

  void _updateControllerAmount() {
    final val = double.tryParse(_amountStr) ?? 0.0;
    ref.read(addTransactionControllerProvider.notifier).setAmount(val);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTransactionControllerProvider);
    final controller = ref.read(addTransactionControllerProvider.notifier);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;

    ref.listen<AddTransactionState>(addTransactionControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: tokens.accentAlert,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Add Transaction',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                child: Column(
                  children: [
                    // Pill Toggles for Expense / Income
                    _buildPillToggles(context, state, controller, tokens),
                    
                    const SizedBox(height: AppSpacing.space6),
                    
                    // Amount Display
                    Text(
                      '\$$_amountStr',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: state.type == TransactionType.expense 
                          ? theme.colorScheme.onSurface 
                          : tokens.accentSavings,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.space2),
                    
                    // Date picker
                    TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: state.date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: tokens.accentTransport,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          controller.setDate(date);
                        }
                      },
                      icon: Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      label: Text(
                        DateFormat.yMMMd().format(state.date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // Note Input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)',
                          border: InputBorder.none,
                          icon: Icon(Icons.edit_note, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        ),
                        onChanged: controller.setNote,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space4),

                    // Category Picker
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    
                    CategoryPicker(
                      selectedCategoryId: state.selectedCategoryId,
                      onCategorySelected: controller.setCategory,
                    ),
                  ],
                ),
              ),
            ),
            
            // Numeric Keypad fixed at bottom
            Container(
              padding: const EdgeInsets.all(AppSpacing.space4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: state.isSaving
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ))
                  : NumericKeypad(
                      onKeyPressed: _onKeyPressed,
                      onBackspace: _onBackspace,
                      onSubmit: () => _handleSave(context, controller),
                      submitLabel: 'Save ${state.type == TransactionType.expense ? "Expense" : "Income"}',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillToggles(BuildContext context, AddTransactionState state, AddTransactionController controller, AppCustomTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setType(TransactionType.expense),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: state.type == TransactionType.expense ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Expense',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: state.type == TransactionType.expense ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setType(TransactionType.income),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: state.type == TransactionType.income ? tokens.accentSavings : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Income',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: state.type == TransactionType.income ? tokens.heroTextColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, AddTransactionController controller) async {
    final overflow = await controller.checkBudgetOverflow();

    if (overflow != null && context.mounted) {
      final action = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Budget Limit Reached'),
          content: Text(
            'This ₹${overflow.projectedSpend.toStringAsFixed(2)} expense will exceed your ₹${overflow.budgetAmount.toStringAsFixed(2)} monthly budget. Remaining: ₹${overflow.remaining.toStringAsFixed(2)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('add_anyway'),
              child: const Text('Add Anyway'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('adjust_budget'),
              child: const Text('Adjust Budget'),
            ),
          ],
        ),
      );

      if (!context.mounted) return;

      if (action == 'cancel' || action == null) {
        return;
      }

      if (action == 'adjust_budget') {
        context.push('/budgets');
        return;
      }
    }

    final success = await controller.saveTransaction();
    if (success && context.mounted) {
      context.pop();
    }
  }
}
