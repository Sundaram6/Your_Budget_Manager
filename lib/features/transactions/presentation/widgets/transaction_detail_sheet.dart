import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../engines/category/category_engine.dart';
import '../../../../engines/transfer/self_transfer_engine_provider.dart';
import '../../domain/entities/transaction.dart';
import '../screens/add_transaction_screen.dart';
import 'category_picker.dart';

class TransactionDetailSheet extends ConsumerStatefulWidget {
  final Transaction transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  ConsumerState<TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends ConsumerState<TransactionDetailSheet> {
  late Transaction _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _updateCategory(String newCategoryId) async {
    final updated = _transaction.copyWith(categoryId: newCategoryId);
    final repo = ref.read(transactionRepositoryProvider);
    await repo.updateTransaction(updated);
    
    if (mounted) {
      setState(() {
        _transaction = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated')),
      );
    }
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 60,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.space4),
                child: Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: CategoryPicker(
                  selectedCategoryId: _transaction.categoryId,
                  onCategorySelected: (categoryId) {
                    Navigator.pop(ctx);
                    _updateCategory(categoryId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTransaction() {
    Navigator.of(context).pop(); // close bottom sheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialTransaction: _transaction),
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    final formatted = _transaction.amount.value.toCurrency();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: Text('Are you sure you want to delete this transaction of $formatted? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.darkExpense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final repo = ref.read(transactionRepositoryProvider);
    await repo.deleteTransaction(_transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>()!;
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categories = categoriesAsync.asData?.value;
    final categoryName = CategoryEngine.getDisplayName(_transaction.categoryId, categories: categories);
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(_transaction.date);
    
    // Determine payment method label (with card last-4 when available)
    String paymentDisplay;
    if (_transaction.paymentMethod != PaymentMethod.unknown) {
      paymentDisplay = _transaction.paymentMethod.displayName;
      if (_transaction.cardLast4 != null && _transaction.cardLast4!.isNotEmpty) {
        paymentDisplay += ' •${_transaction.cardLast4}';
      }
    } else {
      paymentDisplay = 'Unknown';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.darkBorderGlass,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Transaction Details',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (_transaction.isSelfTransfer)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.darkGoldPrimary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.swap_horiz, size: 14, color: AppColors.darkGoldPrimary),
                                    SizedBox(width: 4),
                                    Text('Self Transfer', style: TextStyle(color: AppColors.darkGoldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.darkGoldPrimary),
                            tooltip: 'Edit Transaction',
                            visualDensity: VisualDensity.compact,
                            onPressed: _editTransaction,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.darkExpense),
                            tooltip: 'Delete Transaction',
                            visualDensity: VisualDensity.compact,
                            onPressed: _deleteTransaction,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _transaction.isSelfTransfer
                            ? '↔ ${_transaction.amount.value.toCurrency()}'
                            : _transaction.amount.value.toCurrency(),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _transaction.isSelfTransfer
                              ? AppColors.darkGoldPrimary
                              : (_transaction.type == TransactionType.income ? tokens.incomeColor : tokens.expenseColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _buildDetailRow(context, 'Date & Time', dateStr, Icons.access_time),
                  _buildDetailRow(context, 'Payment Method', paymentDisplay, Icons.credit_card),
                  if (_transaction.accountLast4 != null && _transaction.accountLast4!.isNotEmpty)
                    _buildDetailRow(context, 'Account', 'A/c ending in *${_transaction.accountLast4}', Icons.account_balance),
                  if (_transaction.transactionRef != null && _transaction.transactionRef!.isNotEmpty)
                    _buildDetailRow(context, 'Ref / UTR', _transaction.transactionRef!, Icons.tag),
                  if (_transaction.note != null && _transaction.note!.isNotEmpty)
                    _buildDetailRow(context, 'Note', _transaction.note!, Icons.notes),
                  
                  if (_transaction.isSelfTransfer) ...[
                    const SizedBox(height: AppSpacing.space2),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sync_alt, color: AppColors.darkGoldPrimary, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Linked Self-Transfer Pair', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTextPrimary, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  _transaction.type == TransactionType.expense
                                      ? 'Debit side of transfer'
                                      : 'Credit side of transfer',
                                  style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () async {
                              final selfTransferEngine = ref.read(selfTransferEngineProvider);
                              await selfTransferEngine.unlinkPair(_transaction.transferPairId!);
                              final updated = await ref.read(transactionRepositoryProvider).watchAllTransactions().first;
                              final refreshed = updated.firstWhere((t) => t.id == _transaction.id, orElse: () => _transaction);
                              if (mounted) {
                                setState(() {
                                  _transaction = refreshed;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Transfers unlinked successfully')),
                                );
                              }
                            },
                            child: const Text('Unlink', style: TextStyle(color: AppColors.darkGoldPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.space3),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tokens.accentBills.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.category, color: tokens.accentBills),
                    ),
                    title: Text('Category', style: Theme.of(context).textTheme.bodySmall),
                    subtitle: Text(categoryName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    trailing: TextButton(
                      onPressed: () => _showCategoryPicker(context),
                      child: const Text('Change'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkGoldPrimary,
                            side: const BorderSide(color: AppColors.darkGoldPrimary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _editTransaction,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkExpense,
                            side: const BorderSide(color: AppColors.darkExpense),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _deleteTransaction,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(icon, size: 20, color: AppColors.darkTextTertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.darkTextTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
