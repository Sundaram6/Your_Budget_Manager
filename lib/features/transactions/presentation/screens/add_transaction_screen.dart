import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controllers/add_transaction_controller.dart';
import '../widgets/amount_keypad.dart';
import '../widgets/category_picker.dart';

class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addTransactionControllerProvider);
    final controller = ref.read(addTransactionControllerProvider.notifier);

    // Show error if any
    ref.listen<AddTransactionState>(addTransactionControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _handleSave(context, controller),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Toggle Income / Expense
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                  ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ],
                selected: {state.type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  controller.setType(newSelection.first);
                },
              ),
            ),
            
            // Amount Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    CurrencyFormatter.format(state.amount),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: state.type == TransactionType.expense ? Colors.red : Colors.green,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        controller.setDate(date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat.yMMMd().format(state.date)),
                  ),
                ],
              ),
            ),

            // Note Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: controller.setNote,
              ),
            ),

            // Error display banner if present
            if (state.error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Category Picker
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            CategoryPicker(
              selectedCategoryId: state.selectedCategoryId,
              onCategorySelected: controller.setCategory,
            ),

            // Keypad
            AmountKeypad(
              value: state.amount > 0 ? state.amount.toString().replaceAll(RegExp(r'\.0$'), '') : '',
              onChanged: (val) {
                final amount = double.tryParse(val) ?? 0.0;
                controller.setAmount(amount);
              },
              onSubmit: () => _handleSave(context, controller),
            ),
          ],
        ),
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
