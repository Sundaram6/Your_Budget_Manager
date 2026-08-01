import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/recurring_controller.dart';
import '../widgets/recurring_tile.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recurringControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: state.when(
        data: (transactions) {
          if (transactions.isEmpty) return const Center(child: Text('No recurring transactions.'));
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return RecurringTile(transaction: transactions[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
