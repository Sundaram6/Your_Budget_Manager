import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/providers/database_providers.dart';
import 'core/providers/initial_route_provider.dart';
import 'database/health/database_health_check.dart';
import 'engine/recurring_engine.dart';
import 'engines/category/category_engine_provider.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final count = await RecurringEngine.processDueRecurring();
      debugPrint('Background recurring check generated $count transactions.');
      return Future.value(true);
    } catch (e, stack) {
      debugPrint('Background recurring check error: $e\n$stack');
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Dual-flag check: BOTH the boolean AND a timestamp must be present for
  // onboarding to be considered truly complete. This prevents stale prefs
  // from a previous debug session without a timestamp from silently skipping
  // onboarding on a fresh install of the same APK.
  final hasCompleted = prefs.getBool('hasCompletedOnboarding') ?? false;
  final completedAt = prefs.getInt('onboardingCompletedAt');
  final isOnboardingTrulyComplete = hasCompleted && completedAt != null;

  final container = ProviderContainer(
    overrides: [
      initialRouteProvider.overrideWithValue(
        isOnboardingTrulyComplete ? '/' : '/onboarding',
      ),
    ],
  );

  // 1. Run DatabaseHealthCheck safety net on every startup before any read/write
  final db = container.read(appDatabaseProvider);
  await DatabaseHealthCheck(db).run();

  // 2. Initialize Workmanager for background recurring check
  try {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      'recurring-check-task',
      'recurring-check',
      frequency: const Duration(hours: 6),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
  } catch (e) {
    debugPrint('Workmanager initialization error: $e');
  }

  // 3. Run legacy category migration & default seeding
  await container.read(categoryEngineProvider).seedDefaults();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const YourBudgetManagerApp(),
    ),
  );
}
