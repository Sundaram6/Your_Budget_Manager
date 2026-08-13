import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/security/biometric_service.dart';
import '../../core/security/pin_service.dart';
import '../../core/theme/app_colors.dart';

class PinSecurityScreen extends ConsumerStatefulWidget {
  const PinSecurityScreen({super.key});

  @override
  ConsumerState<PinSecurityScreen> createState() => _PinSecurityScreenState();
}

class _PinSecurityScreenState extends ConsumerState<PinSecurityScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _useBiometric = false;
  bool _lockOnBackground = true;
  bool _hasPin = false;
  bool _isLoading = true;
  bool _isSavingPin = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final pinService = ref.read(pinServiceProvider);
    final hasPin = await pinService.hasPin();
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _useBiometric = prefs.getBool('pref_use_biometric') ?? false;
        _lockOnBackground = prefs.getBool('pref_app_lock') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final biometricService = ref.read(biometricServiceProvider);
        final isAvailable = await biometricService.isBiometricAvailable();

        if (!isAvailable) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication is not available or enrolled on this device'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking biometrics: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_use_biometric', value);
    if (mounted) {
      setState(() => _useBiometric = value);
    }
  }

  Future<void> _toggleLockOnBackground(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_app_lock', value);
    if (mounted) {
      setState(() => _lockOnBackground = value);
    }
  }

  Future<void> _savePin() async {
    if (!_formKey.currentState!.validate()) return;

    final pinService = ref.read(pinServiceProvider);

    setState(() => _isSavingPin = true);

    try {
      if (_hasPin) {
        final isValid = await pinService.verifyPin(_currentPinController.text.trim());
        if (!isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Current PIN is incorrect'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }
      }

      await pinService.setPin(_newPinController.text.trim());

      _currentPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();

      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPin = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PIN & Security',
          style: TextStyle(
            color: AppColors.darkGoldPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.darkGoldPrimary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('BIOMETRIC & LOCK'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            'Use Fingerprint / Face ID',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Authenticate using biometric hardware',
                            style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12),
                          ),
                          value: _useBiometric,
                          activeColor: AppColors.darkGoldPrimary,
                          onChanged: _toggleBiometric,
                        ),
                        const Divider(height: 1, color: Color(0xFF2A2A2A)),
                        SwitchListTile(
                          title: const Text(
                            'Lock app when backgrounded',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Require authentication upon returning to app',
                            style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 12),
                          ),
                          value: _lockOnBackground,
                          activeColor: AppColors.darkGoldPrimary,
                          onChanged: _toggleLockOnBackground,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(_hasPin ? 'CHANGE PIN' : 'SET PIN'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_hasPin) ...[
                          TextFormField(
                            controller: _currentPinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Current PIN'),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your current PIN';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _newPinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(_hasPin ? 'New PIN' : 'Enter 4-6 digit PIN'),
                          validator: (val) {
                            if (val == null || val.length < 4) {
                              return 'PIN must be between 4 and 6 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Confirm New PIN'),
                          validator: (val) {
                            if (val != _newPinController.text) {
                              return 'PINs do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkGoldPrimary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isSavingPin ? null : _savePin,
                            child: _isSavingPin
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : Text(
                                    _hasPin ? 'Update PIN' : 'Save PIN',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.darkTextTertiary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
      counterText: '',
      filled: true,
      fillColor: const Color(0xFF111111),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.darkGoldPrimary),
      ),
    );
  }
}
