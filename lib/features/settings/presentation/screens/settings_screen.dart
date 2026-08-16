import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/glass_card.dart';
import '../../../../routing/route_names.dart';
import '../../../../screens/recurring/recurring_list_screen.dart';
import '../../../../screens/settings/notification_settings_screen.dart';
import '../../../../screens/settings/pin_security_screen.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../budgets/presentation/screens/budget_settings_screen.dart';
import '../../../categories/presentation/screens/category_management_screen.dart';
import '../../../intelligence/presentation/screens/insights_screen.dart';
import '../../../savings/presentation/screens/savings_goals_screen.dart';
import 'about_screen.dart';
import 'appearance_screen.dart';
import 'sms_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
                _buildTile(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.darkGoldPrimary,
                  title: 'Monthly Budget',
                  subtitle: 'Set and manage your spending limit',
                  routeName: RouteNames.budgets,
                  screen: const BudgetSettingsScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.savings_outlined,
                  color: Colors.green,
                  title: 'Savings Goals',
                  subtitle: 'Track and manage your savings',
                  routeName: RouteNames.savingsGoals,
                  screen: const SavingsGoalsScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  color: Colors.purpleAccent,
                  title: 'AI Financial Insights',
                  subtitle: 'View full rule-based financial advice & score',
                  routeName: RouteNames.insights,
                  screen: const InsightsScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.message_outlined,
                  color: Colors.blueAccent,
                  title: 'SMS Auto-Tracking',
                  subtitle: 'Extract expenses from messages',
                  routeName: RouteNames.smsSettings,
                  screen: const SmsSettingsScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.notifications_active_outlined,
                  color: AppColors.darkGoldPrimary,
                  title: 'Payment Notifications',
                  subtitle: 'Auto-track payments from UPI, wallets, and banks',
                  routeName: RouteNames.notificationSettings,
                  screen: const NotificationSettingsScreen(),
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
                  icon: Icons.lock_outline,
                  color: AppColors.darkGoldPrimary,
                  title: 'PIN & Security',
                  subtitle: 'Change PIN, biometric & app lock',
                  routeName: RouteNames.security,
                  screen: const PinSecurityScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.grid_view_rounded,
                  color: AppColors.darkIncome,
                  title: 'Categories',
                  subtitle: 'Manage custom expense categories',
                  routeName: RouteNames.categories,
                  screen: const CategoryManagementScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.autorenew_rounded,
                  color: Colors.blueAccent,
                  title: 'Recurring Transactions',
                  subtitle: 'Bills, subscriptions, and reminders',
                  routeName: RouteNames.recurring,
                  screen: const RecurringListScreen(),
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
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('hasCompletedOnboarding', false);
                    await prefs.setBool('onboarding_complete', false);
                    await prefs.remove('onboardingCompletedAt');
                    await prefs.reload();
                    if (context.mounted) {
                      try {
                        context.go('/onboarding');
                      } catch (_) {}
                    }
                  },
                ),
                if (kDebugMode) ...[
                  const Divider(height: 1, color: AppColors.darkBorderGlass),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bug_report_outlined, color: Colors.redAccent, size: 22),
                    ),
                    title: const Text('Reset Onboarding (Debug)', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Clears all setup flags — simulates fresh install', style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.darkTextTertiary),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset Onboarding?'),
                          content: const Text(
                            'This clears ALL setup flags (onboarding, PIN) to simulate a fresh install. Transactions and budgets are NOT deleted.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm != true) return;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('hasCompletedOnboarding');
                      await prefs.remove('onboarding_complete');
                      await prefs.remove('onboardingCompletedAt');
                      await prefs.remove('hasSkippedPinSetup');
                      await prefs.remove('has_skipped_pin');
                      await prefs.remove('pin_setup_complete');
                      await prefs.remove('pinSetupComplete');
                      await prefs.reload();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All setup flags cleared. Restart the app to see onboarding.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                ],
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
                  routeName: RouteNames.backup,
                  screen: const BackupScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.palette_outlined,
                  color: Colors.orangeAccent,
                  title: 'Appearance',
                  subtitle: 'Dark theme & accent customization',
                  routeName: RouteNames.appearance,
                  screen: const AppearanceScreen(),
                ),
                const Divider(height: 1, color: AppColors.darkBorderGlass),
                _buildTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  color: AppColors.darkTextSecondary,
                  title: 'About App',
                  subtitle: 'Privacy promise & local storage details',
                  routeName: RouteNames.about,
                  screen: const AboutScreen(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
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
    required String routeName,
    Widget? screen,
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
      onTap: () {
        try {
          context.pushNamed(routeName);
        } catch (_) {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          }
        }
      },
    );
  }
}
