import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/security/pin_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_names.dart';
import '../controllers/auth_controller.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMsg = '';
  bool _hasPin = false;
  bool _useBiometric = false;
  bool _isChecking = true;
  bool _isAuthenticating = false;
  int _remainingLockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _checkSecurityConfig();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkSecurityConfig() async {
    final pinService = ref.read(pinServiceProvider);
    final hasPin = await pinService.hasPin();
    final remainingLockout = await pinService.getRemainingLockoutSeconds();
    final prefs = await SharedPreferences.getInstance();
    final useBiometric = prefs.getBool('pref_use_biometric') ?? false;

    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _useBiometric = useBiometric;
        _remainingLockoutSeconds = remainingLockout;
        _isChecking = false;
      });

      if (remainingLockout > 0) {
        _startLockoutCountdown();
      }
    }

    if (useBiometric && remainingLockout <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _attemptBiometric();
        }
      });
    }
  }

  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = await ref.read(pinServiceProvider).getRemainingLockoutSeconds();
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _remainingLockoutSeconds = 0;
          _errorMsg = '';
        });
      } else {
        setState(() {
          _remainingLockoutSeconds = remaining;
        });
      }
    });
  }

  String _formatLockoutMessage(int seconds) {
    if (seconds >= 60) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return 'Too many failed attempts. Try again in ${mins}m ${secs.toString().padLeft(2, '0')}s';
    }
    return 'Too many failed attempts. Try again in ${seconds}s';
  }

  Future<void> _attemptBiometric() async {
    if (_isAuthenticating || _remainingLockoutSeconds > 0) return;
    if (!mounted) return;

    setState(() {
      _isAuthenticating = true;
      _errorMsg = '';
    });

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .authenticateBiometric('Unlock Your Budget Manager');
      if (success && mounted) {
        _lockoutTimer?.cancel();
        context.goNamed(RouteNames.dashboard);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = 'Authentication failed');
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  void _verifyPin() async {
    if (_isAuthenticating || _remainingLockoutSeconds > 0) return;
    setState(() => _errorMsg = '');

    final pinService = ref.read(pinServiceProvider);
    final isLockedOut = await pinService.isLockedOut();
    if (isLockedOut) {
      final remaining = await pinService.getRemainingLockoutSeconds();
      setState(() => _remainingLockoutSeconds = remaining);
      _startLockoutCountdown();
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyPin(_pinController.text.trim());
    if (success && mounted) {
      _lockoutTimer?.cancel();
      context.goNamed(RouteNames.dashboard);
    } else if (mounted) {
      final remaining = await pinService.getRemainingLockoutSeconds();
      if (remaining > 0) {
        setState(() {
          _remainingLockoutSeconds = remaining;
          _errorMsg = '';
          _pinController.clear();
        });
        _startLockoutCountdown();
      } else {
        final failed = await pinService.getFailedAttempts();
        final remainingUntilLockout = 5 - failed;
        if (remainingUntilLockout > 0 && remainingUntilLockout <= 2) {
          setState(() => _errorMsg = 'Invalid PIN. $remainingUntilLockout attempt(s) remaining before lockout.');
        } else {
          setState(() => _errorMsg = 'Invalid PIN');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.darkCanvas,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.darkGoldPrimary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.darkGoldPrimary,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'App Locked',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Text(
                _hasPin
                    ? 'Enter your PIN or use biometrics to continue'
                    : 'Use biometric authentication to unlock',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              if (_remainingLockoutSeconds > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _formatLockoutMessage(_remainingLockoutSeconds),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_hasPin) ...[
                TextField(
                  controller: _pinController,
                  enabled: _remainingLockoutSeconds <= 0,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _remainingLockoutSeconds > 0 ? Colors.grey : Colors.white,
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    hintStyle: const TextStyle(
                      color: AppColors.darkTextTertiary,
                      letterSpacing: 8,
                    ),
                    filled: true,
                    fillColor: _remainingLockoutSeconds > 0 ? AppColors.darkSurface2.withValues(alpha: 0.5) : AppColors.darkSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorderGlass),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorderGlass),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkGoldPrimary),
                    ),
                  ),
                  onChanged: (_) => setState(() => _errorMsg = ''),
                ),
                if (_errorMsg.isNotEmpty && _remainingLockoutSeconds <= 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMsg,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _remainingLockoutSeconds > 0 ? Colors.grey.shade800 : AppColors.darkGoldPrimary,
                      foregroundColor: _remainingLockoutSeconds > 0 ? Colors.white54 : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _remainingLockoutSeconds > 0 ? null : _verifyPin,
                    child: Text(
                      _remainingLockoutSeconds > 0 ? 'Locked Out' : 'Unlock',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],

              if (_useBiometric) ...[
                const SizedBox(height: 24),
                IconButton(
                  icon: Icon(
                    Icons.fingerprint,
                    size: 56,
                    color: _remainingLockoutSeconds > 0 ? Colors.grey : AppColors.darkGoldPrimary,
                  ),
                  tooltip: _remainingLockoutSeconds > 0 ? 'Locked out' : 'Unlock with Biometric',
                  onPressed: _remainingLockoutSeconds > 0 ? null : _attemptBiometric,
                ),
                const SizedBox(height: 8),
                Text(
                  _remainingLockoutSeconds > 0
                      ? 'Biometric unlock paused during lockout'
                      : 'Tap to use Fingerprint / Face ID',
                  style: TextStyle(
                    color: _remainingLockoutSeconds > 0 ? Colors.grey : AppColors.darkTextTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
