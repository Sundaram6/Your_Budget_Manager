import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/transactions/domain/entities/transaction.dart';
import '../../../../features/transactions/presentation/widgets/transaction_detail_sheet.dart';
import '../../../../features/transactions/presentation/widgets/transaction_tile.dart';

class CategoryTransactionsSheet extends ConsumerWidget {
  final String categoryId;
  final String categoryName;
  final int month;
  final int year;
  final Color? categoryColor;

  const CategoryTransactionsSheet({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.month,
    required this.year,
    this.categoryColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String categoryId,
    required String categoryName,
    required int month,
    required int year,
    Color? categoryColor,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryTransactionsSheet(
        categoryId: categoryId,
        categoryName: categoryName,
        month: month,
        year: year,
        categoryColor: categoryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>();
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = categoryColor ?? (isDark ? AppColors.darkGoldPrimary : theme.colorScheme.primary);

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    final periodName = DateFormat('MMMM yyyy').format(DateTime(year, month));

    final txRepo = ref.watch(transactionRepositoryProvider);
    final txStream = txRepo.watchTransactionsByDateRange(start, end);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorderGlass : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              // Top drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            periodName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Transaction Stream Content
              Expanded(
                child: StreamBuilder<List<Transaction>>(
                  stream: txStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allTxs = snapshot.data ?? [];
                    final filtered = allTxs.where((tx) =>
                      tx.categoryId == categoryId &&
                      tx.type == TransactionType.expense &&
                      !tx.isSelfTransfer
                    ).toList();

                    final totalPaise = filtered.fold<int>(0, (sum, tx) => sum + tx.amount.value);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions in $categoryName for $periodName',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      children: [
                        // Summary Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${filtered.length} transaction${filtered.length == 1 ? '' : 's'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatPaiseNoDecimals(totalPaise),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Transaction Tiles
                        ...filtered.map((tx) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Material(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              child: TransactionTile(
                                transaction: tx,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => TransactionDetailSheet(transaction: tx),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
