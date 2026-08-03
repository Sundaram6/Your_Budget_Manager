import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../engines/sms/models/parsed_transaction.dart';

class PendingTransactionTile extends StatelessWidget {
  const PendingTransactionTile({
    super.key,
    required this.transaction,
    this.onAdd,
    this.isConfirming = false,
  });

  final ParsedTransaction transaction;
  final VoidCallback? onAdd;
  final bool isConfirming;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colorScheme.primaryContainer,
          child: Icon(Icons.receipt, color: context.colorScheme.onPrimaryContainer),
        ),
        title: Text(transaction.merchantName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              transaction.originalSmsBody,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Category: ${transaction.categoryId}',
              style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.primary),
            ),

          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              transaction.amount.toCurrency(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.error,
              ),
            ),
            const SizedBox(width: 8),
            if (isConfirming)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (onAdd != null)
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Confirm & Save',
                onPressed: onAdd,
              ),
          ],
        ),
      ),
    );
  }
}
