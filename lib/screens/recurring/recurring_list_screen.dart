import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/recurring_transaction.dart';
import '../../repositories/recurring_repository.dart';
import 'create_recurring_screen.dart';

class RecurringListScreen extends StatelessWidget {
  final Stream<List<RecurringTransactionModel>>? stream;

  const RecurringListScreen({super.key, this.stream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Recurring Transactions',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
            tooltip: 'Add Recurring Payment',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateRecurringScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<RecurringTransactionModel>>(
        stream: stream ?? RecurringRepository.instance.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading recurring transactions: ${snapshot.error}',
                style: const TextStyle(color: AppColors.darkExpense),
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 64,
                    color: AppColors.darkTextPrimary.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  const Text(
                    'No recurring transactions yet',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Recurring Payment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CreateRecurringScreen()),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.space4),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final item = transactions[index];
              return _buildRecurringCard(context, item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateRecurringScreen()),
          );
        },
      ),
    );
  }

  Widget _buildRecurringCard(BuildContext context, RecurringTransactionModel item) {
    final isIncome = item.type.toLowerCase() == 'income';
    final badgeColor = isIncome ? AppColors.darkIncome : AppColors.darkExpense;
    final amountRupees = item.amountPaise / 100.0;
    final formattedAmount = amountRupees % 1 == 0
        ? amountRupees.toStringAsFixed(0)
        : amountRupees.toStringAsFixed(2);
    final nextDueDateFormatted = DateFormat('dd/MM/yyyy').format(item.nextDueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space3),
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorderGlass),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.frequency.toUpperCase(),
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!item.isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PAUSED',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.darkTextTertiary, size: 20),
                color: AppColors.darkSurface3,
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateRecurringScreen(initialRecurring: item),
                      ),
                    );
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Recurring Payment?'),
                        content: Text(
                          'Are you sure you want to delete "${item.title}"?\n\n'
                          'Historical transactions previously generated by this rule will be preserved.',
                        ),
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

                    if (confirm == true) {
                      await RecurringRepository.instance.delete(item.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recurring payment "${item.title}" deleted.')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: AppColors.darkGoldPrimary, size: 18),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.darkExpense, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.darkExpense)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹$formattedAmount • Next: $nextDueDateFormatted',
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
