import 'package:flutter_riverpod/flutter_riverpod.dart';

final initialRouteProvider = Provider<String>((ref) {
  // Default value, overridden synchronously in main.dart
  return '/onboarding';
});
