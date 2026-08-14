import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/security/app_lock_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../services/notification_reader_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _upiEnabled = true;
  bool _walletsEnabled = true;
  bool _bankingEnabled = true;
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final permission = await NotificationReaderService.instance.isPermissionGranted();

    if (mounted) {
      setState(() {
        _upiEnabled = prefs.getBool('pref_notify_upi') ?? true;
        _walletsEnabled = prefs.getBool('pref_notify_wallets') ?? true;
        _bankingEnabled = prefs.getBool('pref_notify_banking') ?? true;
        _hasPermission = permission;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSetting(String key, bool value, Function(bool) updateState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (mounted) {
      setState(() {
        updateState(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              children: [
                // Permission Status Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: _hasPermission
                        ? AppColors.darkIncome.withValues(alpha: 0.15)
                        : AppColors.darkExpense.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasPermission ? AppColors.darkIncome : AppColors.darkExpense,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _hasPermission ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: _hasPermission ? AppColors.darkIncome : AppColors.darkExpense,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasPermission
                                  ? 'Notification Listener Active'
                                  : 'Notification Permission Required',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hasPermission
                                  ? 'Payment notifications will be captured automatically.'
                                  : 'Grant access in Android settings to auto-capture payments.',
                              style: const TextStyle(
                                color: AppColors.darkTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_hasPermission)
                        TextButton(
                          onPressed: () async {
                            ref.read(appLockControllerProvider.notifier).setSystemDialogActive(true);
                            try {
                              await NotificationReaderService.instance.openNotificationSettings();
                            } finally {
                              ref.read(appLockControllerProvider.notifier).setSystemDialogActive(false);
                            }
                            await _loadSettings();
                          },
                          child: const Text(
                            'Grant',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space6),

                // Category Toggles Section
                const Text(
                  'PAYMENT CATEGORIES',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorderGlass),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: [
                      _buildSwitchTile(
                        title: 'UPI Payment Apps',
                        subtitle: 'Google Pay, PhonePe, Paytm, BHIM, CRED, WhatsApp, etc.',
                        icon: Icons.account_balance_wallet,
                        value: _upiEnabled,
                        onChanged: (val) => _toggleSetting(
                          'pref_notify_upi',
                          val,
                          (v) => _upiEnabled = v,
                        ),
                      ),
                      const Divider(color: AppColors.darkBorderGlass, height: 1),
                      _buildSwitchTile(
                        title: 'Digital Wallets',
                        subtitle: 'Paytm Wallet, Amazon Pay Balance, Mobikwik',
                        icon: Icons.account_balance,
                        value: _walletsEnabled,
                        onChanged: (val) => _toggleSetting(
                          'pref_notify_wallets',
                          val,
                          (v) => _walletsEnabled = v,
                        ),
                      ),
                      const Divider(color: AppColors.darkBorderGlass, height: 1),
                      _buildSwitchTile(
                        title: 'Banking SMS & Notifications',
                        subtitle: 'HDFC, SBI, ICICI, Axis, Kotak, INDUSIND debit/credit alerts',
                        icon: Icons.credit_card,
                        value: _bankingEnabled,
                        onChanged: (val) => _toggleSetting(
                          'pref_notify_banking',
                          val,
                          (v) => _bankingEnabled = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                const SizedBox(height: AppSpacing.space6),

                // Privacy Disclaimer Box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorderGlass),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFFD4AF37), size: 24),
                      SizedBox(width: AppSpacing.space3),
                      Expanded(
                        child: Text(
                          'Budget Manager only reads notifications from selected payment apps. All processing is local — nothing is transmitted to any server.',
                          style: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFFD4AF37),
      secondary: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(
        title,
        style: AppTypography.bodyLg.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
