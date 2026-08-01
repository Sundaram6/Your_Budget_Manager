import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/layout/empty_state.dart';
import '../controllers/sms_scan_controller.dart';
import '../widgets/parsed_transaction_tile.dart';

class SmsConsentScreen extends ConsumerWidget {
  const SmsConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(smsScanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SMS Auto-Tracking')),
      body: scanState.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyState(
                    title: 'No Transactions Found',
                    subtitle: 'We scanned your SMS but could not find any recognizable expenses.',
                    lottieAsset: 'assets/animations/empty.json',
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Scan Again',
                    onPressed: () => ref.read(smsScanControllerProvider.notifier).requestPermissionAndScan(),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ParsedTransactionTile(
                transaction: tx,
                onAdd: () {
                  // TODO: Add to DB via TransactionDao
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${tx.merchantName} expense')),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.error)),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Grant Permission',
                onPressed: () => ref.read(smsScanControllerProvider.notifier).requestPermissionAndScan(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
