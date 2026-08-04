import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../services/notification_reader_service.dart';

class NotificationPermissionScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const NotificationPermissionScreen({super.key, this.onCompleted});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool _isGranted = false;
  bool _isFinishing = false;
  Timer? _pollingTimer;

  static const List<String> _supportedApps = [
    'Google Pay',
    'PhonePe',
    'Paytm',
    'Amazon Pay',
    'CRED',
    'WhatsApp',
    'SuperMoney',
    'BHIM UPI',
  ];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final granted =
        await NotificationReaderService.instance.isPermissionGranted();
    if (mounted) {
      setState(() {
        _isGranted = granted;
      });
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 2), (_) async {
      final granted =
          await NotificationReaderService.instance.isPermissionGranted();
      if (mounted && granted) {
        setState(() {
          _isGranted = true;
        });
        _pollingTimer?.cancel();
      }
    });
  }

  Future<void> _grantAccess() async {
    await NotificationReaderService.instance.openNotificationSettings();
    _startPolling();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      await prefs.setBool('onboarding_complete', true);
      await prefs.setInt(
        'onboardingCompletedAt',
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.reload();

      await Future.delayed(const Duration(milliseconds: 200));

      if (widget.onCompleted != null) {
        widget.onCompleted!();
      } else if (mounted) {
        context.go('/');
      }
    } finally {
      if (mounted) {
        setState(() => _isFinishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.space4),
              const Icon(
                Icons.notifications_active_outlined,
                size: 56,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(height: AppSpacing.space4),

              Text(
                'Never miss a transaction',
                style: AppTypography.heading1.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.space3),

              Text(
                'Grant notification access to auto-capture payments from your '
                'favorite UPI and banking apps. All processing happens on your '
                'device — nothing leaves your phone.',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.darkTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              // Supported Payment Apps Grid/Chips
              Text(
                'SUPPORTED APPS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.darkTextTertiary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _supportedApps.map((app) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payment,
                            size: 16, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 6),
                        Text(
                          app,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.space6),

              // Status Banner
              if (_isGranted) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  margin: const EdgeInsets.only(bottom: AppSpacing.space4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Notification access granted. You're all set!",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Primary Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isFinishing
                      ? null
                      : (_isGranted ? _finishOnboarding : _grantAccess),
                  child: _isFinishing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          _isGranted ? 'Continue' : 'Grant Access',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.space3),

              // Skip Button
              Center(
                child: TextButton(
                  onPressed: _isFinishing ? null : _finishOnboarding,
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                        color: AppColors.darkTextSecondary, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
            ],
          ),
        ),
      ),
    );
  }
}
