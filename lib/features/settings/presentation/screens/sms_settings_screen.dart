import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/security/app_lock_controller.dart';
import '../../../../core/utils/platform_guard.dart';
import '../../../../routing/route_names.dart';

class SmsSettingsScreen extends ConsumerStatefulWidget {
  const SmsSettingsScreen({super.key});

  @override
  ConsumerState<SmsSettingsScreen> createState() => _SmsSettingsScreenState();
}

class _SmsSettingsScreenState extends ConsumerState<SmsSettingsScreen> {
  bool _autoTrackSms = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _autoTrackSms = prefs.getBool('autoTrackNewSms') ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAutoTrack(bool value) async {
    if (value) {
      ref.read(appLockControllerProvider.notifier).setSystemDialogActive(true);
      try {
        final status = await Permission.sms.request();
        if (status.isGranted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('autoTrackNewSms', true);
          if (mounted) setState(() => _autoTrackSms = true);
        } else {
          if (mounted) {
            setState(() => _autoTrackSms = false);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('SMS Permission Required'),
                content: const Text('SMS permission is required to automatically detect expenses from bank and UPI alerts.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } finally {
        ref.read(appLockControllerProvider.notifier).setSystemDialogActive(false);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoTrackNewSms', false);
      if (mounted) setState(() => _autoTrackSms = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Auto-Tracking')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!PlatformGuard.isSmsSupported)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: context.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SMS parsing is only supported on Android.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ListTile(
                  title: const Text('Scan Inbox for Expenses'),
                  subtitle: const Text('Find past expenses from Swiggy, Zomato, Uber, etc.'),
                  leading: const Icon(Icons.search),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: PlatformGuard.isSmsSupported 
                      ? () => context.pushNamed(RouteNames.smsConsent)
                      : null,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Auto-track new SMS'),
                  subtitle: const Text('Enable automatic expense tracking from bank and UPI SMS'),
                  value: _autoTrackSms,
                  onChanged: PlatformGuard.isSmsSupported ? _toggleAutoTrack : null,
                ),
              ],
            ),
    );
  }
}
