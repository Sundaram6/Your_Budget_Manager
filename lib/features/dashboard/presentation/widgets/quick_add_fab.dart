import 'package:flutter/material.dart';
import '../../../../core/theme/app_custom_tokens.dart';

class QuickAddFab extends StatelessWidget {
  final VoidCallback onPressed;

  const QuickAddFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>() ?? AppCustomTokens.dark;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: tokens.goldGlow.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'quick_add_fab',
        onPressed: onPressed,
        backgroundColor: tokens.goldAccent,
        foregroundColor: Colors.black, // Dark text/icon on gold background
        child: const Icon(Icons.add),
      ),
    );
  }
}
