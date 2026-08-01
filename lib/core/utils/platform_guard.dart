import 'dart:io';

/// Guards platform-specific features. Use instead of raw Platform.isAndroid
/// to make intent explicit and testable.
abstract class PlatformGuard {
  /// Returns true only on Android — where SMS reading is possible.
  static bool get isSmsSupported => Platform.isAndroid;

  /// Returns true if the current platform supports biometric auth.
  static bool get isBiometricSupported => Platform.isAndroid || Platform.isIOS;
}
