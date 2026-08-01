import 'package:flutter/material.dart';

import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/transactions/domain/entities/transaction.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentTransactionsWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        child: Text('No recent transactions.'),
      );
    }
    
    return Column(
      children: transactions.map((t) {
        return _TransactionItem(transaction: t);
      }).toList(),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: tokens.surfaceGlass,
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
          border: Border.all(color: tokens.borderGlass),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryId, // Ideally category name, but let's use ID or note
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.note!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              transaction.amount.value.toCurrency(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: transaction.amount.value > 0 ? tokens.incomeColor : tokens.expenseColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
