import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../domain/entities/transaction.dart';
import 'category_picker.dart'; // To get categoriesStreamProvider

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => categories.first, // fallback
        );
        
        final isExpense = transaction.type == TransactionType.expense;
        final amountColor = isExpense ? Colors.red : Colors.green;
        final amountPrefix = isExpense ? '-' : '+';
        final formatter = NumberFormat.currency(symbol: '\$');

        return ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Color(category.color).withValues(alpha: 0.2),
            child: Icon(
              // Using a placeholder icon mapping if needed, or just a default
              Icons.category, 
              color: Color(category.color),
            ),
          ),
          title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: transaction.note != null && transaction.note!.isNotEmpty 
              ? Text(transaction.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          trailing: Text(
            '$amountPrefix${formatter.format(transaction.amount.value)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      },
      loading: () => const ListTile(title: Text('Loading...')),
      error: (_, __) => const ListTile(title: Text('Error')),
    );
  }
}
