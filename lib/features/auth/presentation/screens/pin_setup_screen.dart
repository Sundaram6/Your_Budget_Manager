import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../../../../routing/route_names.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isConfirming = false;
  String _errorMsg = '';

  void _onNext() {
    if (!_isConfirming) {
      if (_pinController.text.length < 4) {
        setState(() => _errorMsg = 'PIN must be at least 4 digits');
        return;
      }
      setState(() {
        _isConfirming = true;
        _errorMsg = '';
      });
    } else {
      if (_pinController.text != _confirmPinController.text) {
        setState(() => _errorMsg = 'PINs do not match');
        return;
      }
      ref.read(authControllerProvider.notifier).setupPin(_pinController.text).then((_) {
        context.goNamed(RouteNames.dashboard);
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isConfirming ? 'Confirm your PIN' : 'Create a PIN',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _isConfirming ? _confirmPinController : _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
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
              onPressed: _onNext,
              child: Text(_isConfirming ? 'Save PIN' : 'Next'),
            ),
            if (_isConfirming)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isConfirming = false;
                    _confirmPinController.clear();
                    _errorMsg = '';
                  });
                },
                child: const Text('Back'),
              ),
          ],
        ),
      ),
    );
  }
}
