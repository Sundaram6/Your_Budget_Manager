import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'route_names.dart';
import '../core/security/app_lock_controller.dart';
import '../core/security/pin_service.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/pin_setup_screen.dart';
import '../features/auth/presentation/screens/pin_lock_screen.dart';

part 'app_router.g.dart';

// Provides shared preferences to the router
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final isLocked = ref.watch(appLockControllerProvider);
  
  // We cannot read pinService properly in redirect if we want it synchronous unless we use a provider for hasPin.
  // We'll handle pin lock inside the redirect using the PinService instance directly.

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      final pinService = ref.read(pinServiceProvider);
      final hasPin = await pinService.hasPin();

      final isLockPath = state.matchedLocation == '/pin-lock';
      final isSetupPath = state.matchedLocation == '/pin-setup';
      final isOnboardingPath = state.matchedLocation == '/onboarding';

      if (!isOnboardingComplete) {
        if (isOnboardingPath) return null;
        return '/onboarding';
      }

      if (!hasPin) {
        if (isSetupPath) return null;
        return '/pin-setup';
      }

      if (isLocked) {
        if (isLockPath) return null;
        return '/pin-lock';
      }

      if (isLockPath || isSetupPath || isOnboardingPath) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        name: RouteNames.pinSetup,
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/pin-lock',
        name: RouteNames.pinLock,
        builder: (context, state) => const PinLockScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          // Wrap with any common shell layout here if needed
          return child;
        },
        routes: [
          GoRoute(
            path: '/',
            name: RouteNames.dashboard,
            builder: (context, state) => const DummyDashboard(),
          ),
        ],
      ),
    ],
  );
}

class DummyDashboard extends StatelessWidget {
  const DummyDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard')),
    );
  }
}
