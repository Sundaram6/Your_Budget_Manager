import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../engines/savings/savings_engine_provider.dart';
import '../controllers/savings_controller.dart';
import '../widgets/savings_progress_ring.dart';

class SavingsGoalDetailScreen extends ConsumerWidget {
  const SavingsGoalDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(savingsGoalStreamProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              ref.read(savingsEngineProvider).deleteGoal(id).then((_) {
                if (context.mounted) context.pop();
              });
            },
          ),
        ],
      ),
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (goal) {
          if (goal == null) return const Center(child: Text('Goal not found'));
          
          final color = Color(int.parse('FF${goal.colorHex.replaceAll('#', '')}', radix: 16));

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SavingsProgressRing(
                  progress: goal.progress,
                  color: color,
                  size: 160,
                  strokeWidth: 12,
                  child: Text(
                    '${(goal.progress * 100).toStringAsFixed(0)}%',
                    style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                Text(goal.name, style: context.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '${goal.currentAmount.toCurrency()} / ${goal.targetAmount.toCurrency()}',
                  style: context.textTheme.titleLarge?.copyWith(color: context.colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${goal.remaining.toCurrency()} remaining',
                  style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Add Deposit',
                  onPressed: () => _showDepositSheet(context, ref, goal.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDepositSheet(BuildContext context, WidgetRef ref, String goalId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: _DepositSheetContent(goalId: goalId),
      ),
    );
  }
}

class _DepositSheetContent extends ConsumerStatefulWidget {
  const _DepositSheetContent({required this.goalId});
  final String goalId;

  @override
  ConsumerState<_DepositSheetContent> createState() => _DepositSheetContentState();
}

class _DepositSheetContentState extends ConsumerState<_DepositSheetContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.replaceAll(',', '');
    final amount = double.tryParse(text);
    if (amount != null && amount > 0) {
      ref.read(savingsControllerProvider.notifier).addDeposit(widget.goalId, amount).then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savingsControllerProvider);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Add Deposit', style: context.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (₹)', // Using ₹
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: state.isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: state.isLoading 
              ? const CircularProgressIndicator() 
              : const Text('Confirm Deposit'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
