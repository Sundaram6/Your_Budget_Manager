import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
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
        
        final isTransfer = transaction.isSelfTransfer;
        final isExpense = transaction.type == TransactionType.expense;
        final amountColor = isTransfer
            ? const Color(0xFFD4AF37) // AppColors.darkGoldPrimary
            : (isExpense ? Colors.red : Colors.green);
        final amountPrefix = isTransfer ? '↔ ' : (isExpense ? '-' : '+');

        String? subtitle;
        final hasMethod = transaction.paymentMethod != PaymentMethod.unknown;
        final methodStr = hasMethod
            ? (transaction.cardLast4 != null && transaction.cardLast4!.isNotEmpty
                ? '${transaction.paymentMethod.displayName} •${transaction.cardLast4}'
                : transaction.paymentMethod.displayName)
            : null;

        if (isTransfer) {
          final extra = transaction.note ?? transaction.merchantName;
          subtitle = extra != null && extra.isNotEmpty ? 'Self Transfer • $extra' : 'Self Transfer';
        } else if (transaction.note != null && transaction.note!.isNotEmpty) {
          subtitle = methodStr != null ? '$methodStr • ${transaction.note}' : transaction.note;
        } else {
          subtitle = methodStr;
        }

        final iconBgColor = isTransfer
            ? const Color(0xFFD4AF37).withValues(alpha: 0.2)
            : Color(category.color).withValues(alpha: 0.2);
        final iconColor = isTransfer
            ? const Color(0xFFD4AF37)
            : Color(category.color);

        return ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: iconBgColor,
            child: Icon(
              isTransfer ? Icons.swap_horiz : Icons.category,
              color: iconColor,
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          trailing: Text(
            '$amountPrefix${transaction.amount.value.toCurrency()}',
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
