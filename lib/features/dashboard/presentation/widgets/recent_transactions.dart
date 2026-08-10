import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    final hasNote = transaction.note != null && transaction.note!.trim().isNotEmpty;
    final subtitleText = hasNote ? '$dateStr • ${transaction.note}' : dateStr;

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
              transaction.amount.value.toCurrency(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: transaction.amount.value > 0 ? tokens.incomeColor : tokens.expenseColor,
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
