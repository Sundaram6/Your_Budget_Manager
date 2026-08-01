import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../controllers/savings_controller.dart';

class AddSavingsGoalScreen extends ConsumerStatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  ConsumerState<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends ConsumerState<AddSavingsGoalScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);
    
    if (name.isEmpty || amount == null || amount <= 0) return;
    
    ref.read(savingsControllerProvider.notifier).createGoal(
      name: name,
      targetAmount: amount,
    ).then((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('New Savings Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Goal Name',
              hint: 'e.g. Emergency Fund',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _amountController,
              label: 'Target Amount (₹)', // Using rupee symbol instead of $
              hint: '0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Create Goal',
              isLoading: state.isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
