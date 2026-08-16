import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_custom_tokens.dart';
import '../../theme/app_spacing.dart';

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>() ?? AppCustomTokens.dark;
    
    // Determine current index based on route
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/insights')) currentIndex = 1;
    if (location.startsWith('/transactions')) currentIndex = 2;
    if (location.startsWith('/budgets')) currentIndex = 3;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: child,
      extendBody: true, // Allows body to scroll behind the floating nav bar
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(AppSpacing.space3, 0, AppSpacing.space3, AppSpacing.space3),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.heroSurfaceColor,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: tokens.heroSurfaceColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, tokens, Icons.home_rounded, 'Home', 0, currentIndex),
              _buildNavItem(context, tokens, Icons.pie_chart_rounded, 'Insights', 1, currentIndex),
              _buildNavItem(context, tokens, Icons.list_alt_rounded, 'Txns', 2, currentIndex),
              _buildNavItem(context, tokens, Icons.account_balance_wallet_rounded, 'Budgets', 3, currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, AppCustomTokens tokens, IconData icon, String label, int index, int currentIndex) {
    final isSelected = index == currentIndex;
    
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/insights');
            break;
          case 2:
            context.go('/transactions');
            break;
          case 3:
            context.go('/budgets');
            break;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? tokens.heroTextColor : tokens.heroTextColor.withOpacity(0.5),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.heroTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
