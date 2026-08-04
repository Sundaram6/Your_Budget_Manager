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

  @override
  void initState() {
    super.initState();
    _checkSecurityConfig();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkSecurityConfig() async {
    final pinService = ref.read(pinServiceProvider);
    final hasPin = await pinService.hasPin();
    final prefs = await SharedPreferences.getInstance();
    final useBiometric = prefs.getBool('pref_use_biometric') ?? false;

    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _useBiometric = useBiometric;
        _isChecking = false;
      });
    }

    if (useBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attemptBiometric();
      });
    }
  }

  Future<void> _attemptBiometric() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .authenticateBiometric('Unlock Your Budget Manager');
    if (success && mounted) {
      context.goNamed(RouteNames.dashboard);
    }
  }

  void _verifyPin() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyPin(_pinController.text.trim());
    if (success && mounted) {
      context.goNamed(RouteNames.dashboard);
    } else {
      setState(() => _errorMsg = 'Invalid PIN');
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

              if (_hasPin) ...[
                TextField(
                  controller: _pinController,
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
                    counterText: '',
                    hintText: '••••',
                    hintStyle: const TextStyle(
                      color: AppColors.darkTextTertiary,
                      letterSpacing: 8,
                    ),
                    filled: true,
                    fillColor: AppColors.darkSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorderGlass),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkBorderGlass),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkGoldPrimary),
                    ),
                  ),
                  onChanged: (_) => setState(() => _errorMsg = ''),
                ),
                if (_errorMsg.isNotEmpty) ...[
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
                      backgroundColor: AppColors.darkGoldPrimary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _verifyPin,
                    child: const Text(
                      'Unlock',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],

              if (_useBiometric) ...[
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(
                    Icons.fingerprint,
                    size: 56,
                    color: AppColors.darkGoldPrimary,
                  ),
                  tooltip: 'Unlock with Biometric',
                  onPressed: _attemptBiometric,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap to use Fingerprint / Face ID',
                  style: TextStyle(
                    color: AppColors.darkTextTertiary,
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
