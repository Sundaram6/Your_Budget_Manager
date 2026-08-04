import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pin_service.dart';

part 'app_lock_controller.g.dart';

@Riverpod(keepAlive: true)
class AppLockController extends _$AppLockController with WidgetsBindingObserver {
  bool _isBackgrounded = false;

  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });
    return true; // Locked by default on startup
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached ||
        lifecycleState == AppLifecycleState.hidden) {
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

      if (lockOnBackground && isSecurityActive) {
        state = true;
      }
    } catch (_) {}
  }

  void unlock() {
    state = false;
  }

  void lockNow() {
    state = true;
  }
}
