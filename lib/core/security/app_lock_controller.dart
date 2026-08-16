import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pin_service.dart';

part 'app_lock_controller.g.dart';

@Riverpod(keepAlive: true)
class AppLockController extends _$AppLockController with WidgetsBindingObserver {
  bool _isBackgrounded = false;
  bool _isAuthenticating = false;
  bool _isSystemDialogActive = false;
  Timer? _inactiveTimer;
  AppLifecycleState? _lastLifecycleState;

  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _inactiveTimer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    return true; // Locked by default on startup
  }

  void _logDiagnostic(String message) {
    if (kDebugMode) {
      final now = DateTime.now().toIso8601String();
      developer.log(
        '[$now] [AppLockDiagnostic] $message | state(locked)=$state, '
        'isAuthenticating=$_isAuthenticating, isSystemDialog=$_isSystemDialogActive, '
        'isBackgrounded=$_isBackgrounded, timerActive=${_inactiveTimer?.isActive ?? false}',
        name: 'AppLockController',
      );
    }
  }

  /// Sets whether the app is actively presenting a system authentication prompt
  /// (e.g. Android BiometricPrompt system overlay).
  /// When true, transient window focus loss caused by the prompt overlay will not
  /// prematurely cancel the in-flight authentication flow.
  void setAuthenticating(bool authenticating) {
    _isAuthenticating = authenticating;
    _logDiagnostic('setAuthenticating($authenticating)');
  }

  /// Pauses app-lock inactive debounce evaluation while an external system dialog
  /// (e.g. permission request or notification settings) is displayed.
  void setSystemDialogActive(bool active) {
    _isSystemDialogActive = active;
    _logDiagnostic('setSystemDialogActive($active)');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final previousState = _lastLifecycleState;
    _lastLifecycleState = lifecycleState;
    _logDiagnostic('Lifecycle transition: $previousState -> $lifecycleState');

    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached ||
        lifecycleState == AppLifecycleState.hidden) {
      _inactiveTimer?.cancel();

      // Whenever an unlocked app is paused, hidden, or detached (screen off or app switched),
      // we MUST lock the app immediately, regardless of lingering authentication/dialog flags.
      // If the app is already locked (state == true), we preserve the lock.
      final isCurrentlyUnlocked = !state;
      if (isCurrentlyUnlocked || !_isAuthenticating) {
        _isBackgrounded = true;
        _logDiagnostic('Genuine background/hide event detected -> locking app');
        _evaluateAndLock();
      } else {
        _logDiagnostic('Paused event while locked & authenticating -> suppressed re-lock');
      }
    } else if (lifecycleState == AppLifecycleState.inactive) {
      _inactiveTimer?.cancel();

      // Inactive indicates loss of window focus (notification shade pulled, system dialogs).
      // Debounce briefly (500ms): if app resumes quickly, do not disrupt the user.
      // If app remains inactive for > 500ms outside of active dialogs/auth, lock it.
      if (!_isAuthenticating && !_isSystemDialogActive) {
        _logDiagnostic('Starting 500ms inactive debounce timer');
        _inactiveTimer = Timer(const Duration(milliseconds: 500), () {
          _logDiagnostic('Inactive timer expired (500ms elapsed) -> triggering lock');
          _isBackgrounded = true;
          _evaluateAndLock();
        });
      } else {
        _logDiagnostic('Inactive event ignored due to active dialog or auth session');
      }
    } else if (lifecycleState == AppLifecycleState.resumed) {
      _inactiveTimer?.cancel();
      _isBackgrounded = false;
      _logDiagnostic('Resumed -> cancelled inactive timer, isBackgrounded reset to false');
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

      _logDiagnostic(
        '_evaluateAndLock evaluating: lockOnBackground=$lockOnBackground, '
        'isSecurityActive=$isSecurityActive (hasPin=$hasPin, useBiometric=$useBiometric)',
      );

      if (lockOnBackground && isSecurityActive) {
        state = true;
        _logDiagnostic('AppLockController: Locked state set to true');
      } else {
        _logDiagnostic('AppLockController: Lock not engaged (security inactive or lock disabled)');
      }
    } catch (e, stack) {
      _logDiagnostic('Error evaluating app lock: $e');
      if (kDebugMode) {
        developer.log('Error evaluating app lock', error: e, stackTrace: stack);
      }
    }
  }

  void unlock() {
    _inactiveTimer?.cancel();
    _isAuthenticating = false;
    _isSystemDialogActive = false;
    _isBackgrounded = false;
    state = false;
    _logDiagnostic('AppLockController: Unlocked (state = false)');
  }

  void lockNow() {
    _inactiveTimer?.cancel();
    _isAuthenticating = false;
    _isSystemDialogActive = false;
    state = true;
    _logDiagnostic('AppLockController: Locked immediately (state = true)');
  }
}
