import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../database/database_helper.dart';
import '../services/notification_reader_service.dart';
import '../services/notification_router.dart';

class NotificationTransactionSheet extends StatelessWidget {
  final PaymentNotificationData data;

  const NotificationTransactionSheet({
    super.key,
    required this.data,
  });

  Future<void> _addToBudget(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final tx = await NotificationRouter.instance.toTransaction(data);
      await DatabaseHelper.instance.insertTransaction(tx);
      NotificationRouter.instance.clearPending();

      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Transaction saved',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFFD4AF37),
            duration: Duration(seconds: 3),
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      if (context.mounted) {
        NotificationRouter.instance.clearPending();
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    }
  }

  void _ignore(BuildContext context) {
    NotificationRouter.instance.clearPending();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = data.type.toLowerCase() == 'expense';
    final badgeColor = isExpense ? AppColors.darkExpense : AppColors.darkIncome;
    final headerLabel = isExpense ? 'Payment Detected' : 'Money Received';

    final formattedAmount = data.amount % 1 == 0
        ? data.amount.toStringAsFixed(0)
        : data.amount.toStringAsFixed(2);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkCanvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),

              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                      color: badgeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerLabel,
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹$formattedAmount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space6),

              // Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorderGlass),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('From', data.appName),
                    const Divider(color: AppColors.darkBorderGlass, height: 16),
                    _buildDetailRow('Merchant / Party', data.merchant ?? 'Unknown'),
                    if (data.reference != null && data.reference!.isNotEmpty) ...[
                      const Divider(color: AppColors.darkBorderGlass, height: 16),
                      _buildDetailRow('Reference', data.reference!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.darkBorderGlass),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _ignore(context),
                      child: const Text(
                        'Ignore',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _addToBudget(context),
                      child: const Text(
                        'Add to Budget',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
