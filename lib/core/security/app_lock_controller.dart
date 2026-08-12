import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pin_service.dart';

part 'app_lock_controller.g.dart';

@Riverpod(keepAlive: true)
class AppLockController extends _$AppLockController with WidgetsBindingObserver {
  bool _isBackgrounded = false;
  bool _isAuthenticating = false;

  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });
    return true; // Locked by default on startup
  }

  /// Sets whether the app is actively presenting a system authentication prompt
  /// (e.g. Android BiometricPrompt system overlay). When true, lifecycle pauses
  /// triggered by the system dialog will not cause the app to falsely re-lock.
  void setAuthenticating(bool authenticating) {
    _isAuthenticating = authenticating;
    developer.log('AppLockController: setAuthenticating($authenticating)');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    developer.log('AppLockController lifecycle change: $lifecycleState (isAuthenticating: $_isAuthenticating)');

    // Ignore lifecycle transitions caused by the OS presenting system dialogs
    if (_isAuthenticating) return;

    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached ||
        lifecycleState == AppLifecycleState.hidden ||
        lifecycleState == AppLifecycleState.inactive) {
      if (!_isBackgrounded) {
        _isBackgrounded = true;
        _evaluateAndLock();
      }
    } else if (lifecycleState == AppLifecycleState.resumed) {
      _isBackgrounded = false;
    }
  }

  Future<void> _evaluateAndLock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockOnBackground = prefs.getBool('pref_app_lock') ?? true;
      final useBiometric = prefs.getBool('pref_use_biometric') ?? false;
      final pinService = ref.read(pinServiceProvider);
      final hasPin = await pinService.hasPin();

      final isSecurityActive = hasPin || useBiometric;

      // Lock the app whenever a background or screen-lock event occurred outside of authentication
      if (!_isAuthenticating && lockOnBackground && isSecurityActive) {
        state = true;
        developer.log('AppLockController: Locked state set to true');
      }
    } catch (e, stack) {
      developer.log('Error evaluating app lock', error: e, stackTrace: stack);
    }
  }

  void unlock() {
    state = false;
    developer.log('AppLockController: Unlocked (state = false)');
  }

  void lockNow() {
    state = true;
    developer.log('AppLockController: Locked immediately (state = true)');
  }
}
