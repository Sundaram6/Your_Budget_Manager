import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  bool _isBulkConfirming = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingTransactionsControllerProvider);
    final controller = ref.read(pendingTransactionsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Transactions'),
        actions: [
          if (state.transactions.isNotEmpty)
            TextButton(
              onPressed: _isBulkConfirming
                  ? null
                  : () async {
                      setState(() {
                        _isBulkConfirming = true;
                      });
                      try {
                        final count = await controller.confirmAllTransactions();
                        if (!context.mounted) return;
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('$count transactions saved successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to confirm all: $e'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isBulkConfirming = false;
                          });
                        }
                      }
                    },
              child: _isBulkConfirming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Import All',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Scan Options',
            onPressed: () => _showScanOptions(context, controller),
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
                        label: 'Choose Scan Mode',
                        onPressed: () => _showScanOptions(context, controller),
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
                            onPressed: () => _showScanOptions(context, controller),
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
                            'Scanned ${state.scannedSmsCount} transactions — ${state.transactions.length} pending transactions detected',
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
                                        messenger.clearSnackBars();
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: const Text('Transaction saved'),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 2),
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
                                      messenger.clearSnackBars();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to save ${tx.merchantName}: $e'),
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                          duration: const Duration(seconds: 3),
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

  void _showScanOptions(BuildContext context, PendingTransactionsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171A23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan Inbox',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select which transactions to import',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFFF5D395)),
                title: const Text('This Month', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('Scan transactions from ${DateFormat('MMMM yyyy').format(DateTime.now())}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  controller.scanByMonth(DateTime.now().year, DateTime.now().month);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Color(0xFFF5D395)),
                title: const Text('Last Month', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('Scan transactions from ${DateFormat('MMMM yyyy').format(DateTime(DateTime.now().year, DateTime.now().month - 1))}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  final now = DateTime.now();
                  final lastMonth = DateTime(now.year, now.month - 1);
                  controller.scanByMonth(lastMonth.year, lastMonth.month);
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range, color: Color(0xFFF5D395)),
                title: const Text('Choose Month', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Pick a specific month to scan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await _showMonthPicker(context);
                  if (picked != null) {
                    controller.scanByMonth(picked.year, picked.month);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.all_inclusive, color: Color(0xFFF5D395)),
                title: const Text('All Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Scan all historical SMS messages', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  controller.scanAllTime();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _showMonthPicker(BuildContext context) async {
    final now = DateTime.now();
    DateTime selectedDate = DateTime(now.year, now.month);

    return showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171A23),
        title: const Text('Select Month', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          height: 200,
          child: YearPicker(
            firstDate: DateTime(now.year - 5),
            lastDate: now,
            selectedDate: selectedDate,
            onChanged: (selectedYearDateTime) async {
              final selectedYear = selectedYearDateTime.year;
              final month = await showDialog<int>(
                context: context,
                builder: (context) => SimpleDialog(
                  backgroundColor: const Color(0xFF171A23),
                  title: const Text('Select Month', style: TextStyle(color: Colors.white)),
                  children: List.generate(12, (i) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, i + 1),
                    child: Text(
                      DateFormat('MMMM').format(DateTime(selectedYear, i + 1)),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
                ),
              );
              if (month != null && context.mounted) {
                Navigator.pop(context, DateTime(selectedYear, month));
              }
            },
          ),
        ),
      ),
    );
  }
}
