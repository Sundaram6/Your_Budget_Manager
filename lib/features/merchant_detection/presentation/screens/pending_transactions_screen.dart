import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/layout/empty_state.dart';
import '../controllers/pending_transactions_controller.dart';
import '../widgets/pending_transaction_tile.dart';

class PendingTransactionsScreen extends ConsumerStatefulWidget {
  const PendingTransactionsScreen({super.key});

  @override
  ConsumerState<PendingTransactionsScreen> createState() => _PendingTransactionsScreenState();
}

class _PendingTransactionsScreenState extends ConsumerState<PendingTransactionsScreen> {
  final Map<String, bool> _confirmingMap = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingTransactionsControllerProvider);
    final controller = ref.read(pendingTransactionsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rescan Inbox',
            onPressed: () => _showScanDialog(context, controller),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Scanning SMS inbox...'),
                ],
              ),
            )
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.error}',
                        style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Grant Permission & Scan',
                        onPressed: () => _showScanDialog(context, controller),
                      ),
                    ],
                  ),
                )
              : state.transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const EmptyState(
                            title: 'No Pending Transactions',
                            subtitle: 'We scanned your SMS inbox but found no pending transactions.',
                            lottieAsset: 'assets/animations/empty.json',
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Scan SMS Inbox',
                            onPressed: () => _showScanDialog(context, controller),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: context.colorScheme.surfaceContainerHighest,
                          width: double.infinity,
                          child: Text(
                            'Scanned ${state.scannedSmsCount} historical SMS messages — ${state.transactions.length} pending transactions detected',
                            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.transactions.length,
                            itemBuilder: (context, index) {
                              final tx = state.transactions[index];
                              final isConfirming = _confirmingMap[tx.smsId] ?? false;

                              return PendingTransactionTile(
                                transaction: tx,
                                isConfirming: isConfirming,
                                onAdd: () async {
                                  setState(() {
                                    _confirmingMap[tx.smsId] = true;
                                  });

                                  try {
                                    final success = await controller.confirmTransaction(tx);

                                    if (!context.mounted) return;
                                    final messenger = ScaffoldMessenger.of(context);

                                    if (mounted) {
                                      setState(() {
                                        _confirmingMap.remove(tx.smsId);
                                      });

                                      if (success) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text('Transaction saved'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    final messenger = ScaffoldMessenger.of(context);
                                    if (mounted) {
                                      setState(() {
                                        _confirmingMap.remove(tx.smsId);
                                      });
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to save ${tx.merchantName}: $e'),
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                          duration: const Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  void _showScanDialog(BuildContext context, PendingTransactionsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Inbox'),
        content: const Text(
          'Select scan mode:\n\n'
          '• Fast Scan: Scans latest 1,000 SMS messages.\n'
          '• Full Historical Scan: Scans all inbox messages.',
        ),
        actions: [
          TextButton(
            child: const Text('Scan Last 1,000'),
            onPressed: () {
              Navigator.pop(context);
              controller.requestPermissionAndScan(limit: 1000);
            },
          ),
          ElevatedButton(
            child: const Text('Full Historical Scan'),
            onPressed: () {
              Navigator.pop(context);
              controller.requestPermissionAndScan(limit: null);
            },
          ),
        ],
      ),
    );
  }
}
