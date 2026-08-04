import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/app_lock_controller.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../screens/settings/pin_security_screen.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinService = ref.watch(pinServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Security & Privacy')),
      body: FutureBuilder<bool>(
        future: pinService.hasPin(),
        builder: (context, snapshot) {
          final hasPin = snapshot.data ?? false;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Require PIN / Lock Screen'),
                subtitle: Text(hasPin ? 'PIN protection is active' : 'No PIN configured'),
                value: hasPin,
                onChanged: (val) async {
                  if (val) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PinSecurityScreen()),
                    );
                  } else {
                    await pinService.removePin();
                    ref.read(appLockControllerProvider.notifier).unlock();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN security disabled.')),
                      );
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Change PIN'),
                enabled: hasPin,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PinSecurityScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
