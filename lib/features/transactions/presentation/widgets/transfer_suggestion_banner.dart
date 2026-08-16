import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../engines/transfer/models/transfer_match_result.dart';
import '../../../../engines/transfer/self_transfer_engine_provider.dart';

class TransferSuggestionBanner extends ConsumerWidget {
  const TransferSuggestionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(transferSuggestionsProvider);
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final topSuggestion = suggestions.first;
    final amountFormatted = CurrencyFormatter.formatPaise(topSuggestion.sourceTransaction.amount.value);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz, color: AppColors.darkGoldPrimary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Suggested Self-Transfer',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGoldPrimary,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 18, color: AppColors.darkTextTertiary),
                tooltip: 'Dismiss',
                onPressed: () {
                  ref.read(transferSuggestionsProvider.notifier).dismissSuggestion(topSuggestion);
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Looks like this $amountFormatted might be a transfer between your accounts — link them so it doesn\'t affect your budget?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.darkTextSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(transferSuggestionsProvider.notifier).dismissSuggestion(topSuggestion);
                },
                child: const Text('Dismiss', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGoldPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.link, size: 16),
                label: const Text('Link as Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () async {
                  await ref.read(transferSuggestionsProvider.notifier).linkSuggestion(topSuggestion);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Linked self-transfer successfully')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
