import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/glass_card.dart';
import '../../../../routing/route_names.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../categories/presentation/screens/category_management_screen.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';
import '../../../recurring/presentation/screens/recurring_transactions_screen.dart';
import 'about_screen.dart';
import 'appearance_screen.dart';
import 'security_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.darkGoldPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'FEATURES',
            style: TextStyle(
              color: AppColors.darkTextTertiary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: AppColors.darkGoldPrimary),
                  title: const Text('Monthly Budget', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Set and manage your spending limit', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
                  onTap: () => context.pushNamed(RouteNames.budgets),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                ListTile(
                  leading: const Icon(Icons.savings, color: Colors.green),
                  title: const Text('Savings Goals', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Track and manage your savings', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
                  onTap: () => context.pushNamed(RouteNames.savingsGoals),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                ListTile(
                  leading: const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                  title: const Text('AI Financial Insights', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('View full rule-based financial advice & score', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
                  onTap: () => context.push('/insights'),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                ListTile(
                  leading: const Icon(Icons.message, color: Colors.blue),
                  title: const Text('SMS Auto-Tracking', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Extract expenses from messages', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
                  onTap: () => context.pushNamed(RouteNames.smsSettings),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'PREFERENCES & SECURITY',
            style: TextStyle(
              color: AppColors.darkTextTertiary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildTile(
                  context,
                  icon: Icons.shield_outlined,
                  color: AppColors.darkGoldPrimary,
                  title: 'Security & App Lock',
                  subtitle: 'PIN protection and authentication',
                  screen: const SecuritySettingsScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.grid_view_rounded,
                  color: AppColors.darkIncome,
                  title: 'Categories',
                  subtitle: 'Manage custom expense categories',
                  screen: const CategoryManagementScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.autorenew_rounded,
                  color: Colors.blueAccent,
                  title: 'Recurring Transactions',
                  subtitle: 'Bills, subscriptions, and reminders',
                  screen: const RecurringTransactionsScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.darkGoldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.replay_outlined, color: AppColors.darkGoldPrimary, size: 22),
                  ),
                  title: const Text('Replay Onboarding', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Restart initial setup flow', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
                  onTap: () async {
                    await ref.read(onboardingControllerProvider.notifier).resetOnboarding();
                    if (context.mounted) {
                      context.go('/onboarding');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'DATA & APP',
            style: TextStyle(
              color: AppColors.darkTextTertiary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildTile(
                  context,
                  icon: Icons.cloud_sync_outlined,
                  color: Colors.purpleAccent,
                  title: 'Backup & Restore',
                  subtitle: 'Export encrypted JSON backup',
                  screen: const BackupScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.palette_outlined,
                  color: Colors.orangeAccent,
                  title: 'Appearance',
                  subtitle: 'Dark theme & accent customization',
                  screen: const AppearanceScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  color: AppColors.darkTextSecondary,
                  title: 'About App',
                  subtitle: 'Privacy promise & local storage details',
                  screen: const AboutScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.darkTextTertiary, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
    );
  }
}
