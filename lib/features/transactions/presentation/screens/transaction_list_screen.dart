import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../screens/analytics/monthly_analytics_screen.dart';
import '../controllers/transaction_list_controller.dart';
import '../widgets/transaction_timeline_card.dart';
import '../widgets/transfer_suggestion_banner.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(transactionListControllerProvider);
    final controller = ref.read(transactionListControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          stateAsync.when(
            data: (state) => IconButton(
              icon: const Icon(Icons.bar_chart, color: AppColors.darkGoldPrimary),
              tooltip: 'Monthly Analytics',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MonthlyAnalyticsScreen(
                    initialMonth: state.selectedMonth,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          return Column(
            children: [
              // Month Selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        final newMonth = DateTime(state.selectedMonth.year, state.selectedMonth.month - 1);
                        controller.changeMonth(newMonth);
                      },
                    ),
                    Text(
                      DateFormat.yMMMM().format(state.selectedMonth),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        final newMonth = DateTime(state.selectedMonth.year, state.selectedMonth.month + 1);
                        controller.changeMonth(newMonth);
                      },
                    ),
                  ],
                ),
              ),
              const TransferSuggestionBanner(),
              Expanded(
                child: state.groupedTransactions.isEmpty
                    ? const Center(child: Text('No transactions for this month.'))
                    : ListView.builder(
                        itemCount: state.groupedTransactions.length,
                        itemBuilder: (context, index) {
                          final date = state.groupedTransactions.keys.elementAt(index);
                          final transactions = state.groupedTransactions[date]!;
                          return TransactionTimelineCard(
                            date: date,
                            transactions: transactions,
                          ).animateEntrance(context, index: index);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
