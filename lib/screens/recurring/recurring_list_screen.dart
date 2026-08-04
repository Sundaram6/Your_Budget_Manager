import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/recurring_transaction.dart';
import '../../repositories/recurring_repository.dart';

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
          'Recurring',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<RecurringTransactionModel>>(
        stream: stream ?? RecurringRepository.instance.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
                    color: AppColors.darkTextPrimary.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  const Text(
                    'No recurring transactions yet',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 16,
                    ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Recurring Transaction coming soon!')),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
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
              if (!item.isActive)
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
