import 'package:flutter/material.dart';

import '../../theme/app_custom_tokens.dart';

class MerchantSticker extends StatelessWidget {
  final String merchantName;
  final Color? categoryColor;
  final double size;

  const MerchantSticker({
    super.key,
    required this.merchantName,
    this.categoryColor,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;
    
    // Determine the base color based on merchant name for mockup consistency
    // e.g. Swiggy = orange, Uber = black/grey, Amazon = blue/orange
    final bgColor = _getMerchantColor(merchantName, categoryColor ?? tokens.accentShopping);
    final isDarkBg = bgColor.computeLuminance() < 0.5;
    final textColor = isDarkBg ? Colors.white : Colors.black87;

    final initial = merchantName.isNotEmpty ? merchantName.substring(0, 1).toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.3), // Squircle-ish
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Color _getMerchantColor(String name, Color fallback) {
    final lower = name.toLowerCase();
    if (lower.contains('uber')) return const Color(0xFF121212);
    if (lower.contains('swiggy')) return const Color(0xFFFC8019);
    if (lower.contains('zomato')) return const Color(0xFFE23744);
    if (lower.contains('amazon')) return const Color(0xFF232F3E);
    if (lower.contains('netflix')) return const Color(0xFFE50914);
    if (lower.contains('spotify')) return const Color(0xFF1DB954);
    if (lower.contains('starbucks')) return const Color(0xFF00704A);
    if (lower.contains('apple')) return const Color(0xFF000000);
    return fallback;
  }
}
