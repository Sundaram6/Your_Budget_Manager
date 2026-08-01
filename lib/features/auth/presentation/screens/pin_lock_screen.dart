import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../../routing/route_names.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptBiometric();
    });
  }

  Future<void> _attemptBiometric() async {
    final success = await ref.read(authControllerProvider.notifier).authenticateBiometric('Unlock Your Budget Manager');
    if (success && mounted) {
      context.goNamed(RouteNames.dashboard);
    }
  }

  void _verifyPin() async {
    final success = await ref.read(authControllerProvider.notifier).verifyPin(_pinController.text);
    if (success && mounted) {
      context.goNamed(RouteNames.dashboard);
    } else {
      setState(() => _errorMsg = 'Invalid PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.amber),
            const SizedBox(height: 24),
            Text('Enter PIN', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '****',
              ),
              onChanged: (_) => setState(() => _errorMsg = ''),
            ),
            if (_errorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorMsg, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyPin,
              child: const Text('Unlock'),
            ),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.fingerprint, size: 48),
              onPressed: _attemptBiometric,
            ),
          ],
        ),
      ),
    );
  }
}
