import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../engines/sms/models/parsed_transaction.dart';

class ParsedTransactionTile extends StatelessWidget {
  const ParsedTransactionTile({
    super.key,
    required this.transaction,
    this.onAdd,
  });

  final ParsedTransaction transaction;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.primaryContainer,
        child: Icon(Icons.receipt, color: context.colorScheme.onPrimaryContainer),
      ),
      title: Text(transaction.merchantName),
      subtitle: Text(transaction.originalSmsBody,
          maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(transaction.amount.toCurrency(),
              style: context.textTheme.titleMedium),
          if (onAdd != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: onAdd,
            ),
          ]
        ],
      ),
    );
  }
}
