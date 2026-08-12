import 'package:flutter/material.dart';

import '../../theme/app_custom_tokens.dart';
import '../../utils/currency_formatter.dart';
import 'merchant_sticker.dart';

class TransactionRow extends StatelessWidget {
  final String merchantName;
  final String category;
  final int amount; // Integer paise
  final DateTime date;
  final Color categoryColor;
  final bool isIncome;
  final VoidCallback? onTap;

  const TransactionRow({
    super.key,
    required this.merchantName,
    required this.category,
    required this.amount,
    required this.date,
    required this.categoryColor,
    this.isIncome = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;
    
    final formattedAmount = isIncome
        ? '+${CurrencyFormatter.formatPaise(amount)}'
        : '-${CurrencyFormatter.formatPaise(amount)}';
    
    // In dark mode, text might be slightly different. We use onSurface for primary text.
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.cardBorderRadius / 2),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.gridUnit * 2,
          vertical: tokens.gridUnit * 1.5,
        ),
        child: Row(
          children: [
            MerchantSticker(
              merchantName: merchantName,
              categoryColor: categoryColor,
            ),
            SizedBox(width: tokens.gridUnit * 1.5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchantName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.gridUnit),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedAmount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isIncome ? tokens.accentSavings : primaryTextColor,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    // Basic formatting for now. In real app, we'd use intl
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    } else if (d.year == now.year && d.month == now.month && d.day == now.day - 1) {
      return 'Yesterday';
    }
    return '${d.month}/${d.day}';
  }
}
