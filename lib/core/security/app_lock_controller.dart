import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lock_controller.g.dart';

@Riverpod(keepAlive: true)
class AppLockController extends _$AppLockController with WidgetsBindingObserver {
  Timer? _lockTimer;
  static const _lockTimeout = Duration(minutes: 2);
  bool _isBackgrounded = false;

  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _lockTimer?.cancel();
    });
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      if (!_isBackgrounded) {
        _isBackgrounded = true;
        _startLockTimer();
      }
    } else if (state == AppLifecycleState.resumed) {
      _isBackgrounded = false;
      _lockTimer?.cancel();
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer(_lockTimeout, () {
      state = true;
    });
  }

  void unlock() {
    state = false;
  }

  void lockNow() {
    state = true;
  }
}
