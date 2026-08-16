import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../engines/category/category_engine.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/widgets/category_picker.dart';
import '../../../transactions/presentation/widgets/transaction_detail_sheet.dart';

class RecentTransactionsWidget extends ConsumerWidget {
  final List<Transaction> transactions;

  const RecentTransactionsWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space4),
        child: Text(
          'No recent transactions.',
          style: TextStyle(color: AppColors.darkTextTertiary),
        ),
      );
    }

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.asData?.value;

    return Column(
      children: transactions.map((t) {
        return _TransactionItem(
          transaction: t,
          categoryName: CategoryEngine.getDisplayName(t.categoryId, categories: categories),
        );
      }).toList(),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final String categoryName;

  const _TransactionItem({
    required this.transaction,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    final dateStr = DateFormat('dd MMM yyyy').format(transaction.date);
    final hasMethod = transaction.paymentMethod != PaymentMethod.unknown;
    final methodStr = hasMethod
        ? (transaction.cardLast4 != null && transaction.cardLast4!.isNotEmpty
            ? '${transaction.paymentMethod.displayName} •${transaction.cardLast4}'
            : transaction.paymentMethod.displayName)
        : null;
    final hasNote = transaction.note != null && transaction.note!.trim().isNotEmpty;

    final isTransfer = transaction.isSelfTransfer;
    final isIncome = transaction.type == TransactionType.income;
    final amountFormatted = isTransfer
        ? '↔ ${transaction.amount.value.toCurrency()}'
        : transaction.amount.value.toCurrency();
    final amountColor = isTransfer
        ? AppColors.darkGoldPrimary
        : (isIncome ? tokens.incomeColor : tokens.expenseColor);

    String subtitleText = dateStr;
    if (isTransfer) {
      final extra = transaction.note ?? transaction.merchantName;
      subtitleText = extra != null && extra.isNotEmpty
          ? '$dateStr • Self Transfer • $extra'
          : '$dateStr • Self Transfer';
    } else if (methodStr != null && hasNote) {
      subtitleText = '$dateStr • $methodStr • ${transaction.note}';
    } else if (methodStr != null) {
      subtitleText = '$dateStr • $methodStr';
    } else if (hasNote) {
      subtitleText = '$dateStr • ${transaction.note}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => TransactionDetailSheet(transaction: transaction),
          );
        },
        child: Container(
        padding: const EdgeInsets.all(AppSpacing.space3),
        decoration: BoxDecoration(
          color: tokens.surfaceGlass,
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
          border: Border.all(color: tokens.borderGlass),
        ),
        child: Row(
          children: [
            if (isTransfer) ...[
              const Icon(Icons.swap_horiz, color: AppColors.darkGoldPrimary, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTextPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.darkTextTertiary,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              amountFormatted,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
