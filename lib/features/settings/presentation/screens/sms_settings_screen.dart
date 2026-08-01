import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../routing/route_names.dart';
import '../../../../core/utils/platform_guard.dart';

class SmsSettingsScreen extends ConsumerWidget {
  const SmsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS Auto-Tracking')),
      body: ListView(
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
            subtitle: const Text('Automatically parse and categorise incoming messages (Coming soon in Intelligence Engine)'),
            value: false,
            onChanged: PlatformGuard.isSmsSupported ? (val) {} : null,
          ),
        ],
      ),
    );
  }
}
