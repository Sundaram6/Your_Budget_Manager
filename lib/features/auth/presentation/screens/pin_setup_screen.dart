import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/security/biometric_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _isConfirming = false;
  bool _isSaving = false;
  bool _showBiometricPrompt = false;
  String _errorMsg = '';

  Future<void> _onNext() async {
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
      setState(() => _isSaving = true);
      try {
        final authController = ref.read(authControllerProvider.notifier);
        await authController.setupPin(_pinController.text.trim());

        final biometricService = ref.read(biometricServiceProvider);
        final isBiometricAvailable = await biometricService.isBiometricAvailable();

        if (isBiometricAvailable && mounted) {
          setState(() {
            _showBiometricPrompt = true;
            _isSaving = false;
          });
          return;
        }

        if (mounted) context.go('/');
      } finally {
        if (mounted && !_showBiometricPrompt) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Future<void> _enableBiometric() async {
    setState(() => _isSaving = true);
    try {
      final biometricService = ref.read(biometricServiceProvider);
      final confirmed = await biometricService.authenticate('Confirm biometric enrollment');
      if (confirmed) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pref_use_biometric', true);
        await prefs.setBool('pref_app_lock', true);
        await prefs.reload();
      }
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _skipBiometric() {
    context.go('/');
  }

  /// Skip writes prefs DIRECTLY and navigates immediately on the FIRST tap.
  Future<void> _skipPin() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.skipPinSetup();

      if (context.mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
    if (_showBiometricPrompt) {
      return Scaffold(
        backgroundColor: AppColors.darkCanvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Biometric Security'),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              shape: BoxShape.circle,
                              border: Border(
                                top: BorderSide(color: AppColors.darkGoldPrimary, width: 2),
                                bottom: BorderSide(color: AppColors.darkGoldPrimary, width: 2),
                                left: BorderSide(color: AppColors.darkGoldPrimary, width: 2),
                                right: BorderSide(color: AppColors.darkGoldPrimary, width: 2),
                              ),
                            ),
                            child: const Icon(
                              Icons.fingerprint,
                              size: 48,
                              color: AppColors.darkGoldPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Enable Biometric Unlock?',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.darkTextPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Use Fingerprint or Face ID for faster, secure access to your budget manager.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkGoldPrimary,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isSaving ? null : _enableBiometric,
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Enable Biometrics',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isSaving ? null : _skipBiometric,
                            child: const Text(
                              'Skip for now',
                              style: TextStyle(color: AppColors.darkTextTertiary),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Setup PIN'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Text(
                          _isConfirming ? 'Confirm your PIN' : 'Create a PIN',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _isConfirming ? _confirmPinController : _pinController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: '••••',
                            hintStyle: const TextStyle(
                              color: AppColors.darkTextTertiary,
                              letterSpacing: 8,
                            ),
                            filled: true,
                            fillColor: AppColors.darkSurface2,
                          ),
                          onChanged: (_) => setState(() => _errorMsg = ''),
                        ),
                        if (_errorMsg.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMsg,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkGoldPrimary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSaving ? null : _onNext,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    _isConfirming ? 'Save PIN' : 'Next',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        if (!_isConfirming)
                          TextButton(
                            onPressed: _isSaving ? null : _skipPin,
                            child: const Text(
                              'Skip',
                              style: TextStyle(color: AppColors.darkTextTertiary),
                            ),
                          ),
                        if (_isConfirming)
                          TextButton(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    setState(() {
                                      _isConfirming = false;
                                      _confirmPinController.clear();
                                      _errorMsg = '';
                                    });
                                  },
                            child: const Text(
                              'Back',
                              style: TextStyle(color: AppColors.darkTextTertiary),
                            ),
                          ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
