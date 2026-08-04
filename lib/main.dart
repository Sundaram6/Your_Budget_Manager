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
import 'services/notification_reader_service.dart';

/*
 * ============================================================================
 * PHASE 4 TESTING CHECKLIST:
 * ============================================================================
 * 1. Create daily recurring with past date -> should generate on next app open
 * 2. Background WorkManager fires every 6 hours
 * 3. Real UPI payment triggers bottom sheet within 1-2 seconds
 * 4. Tapping "Add to Budget" saves transaction with isAutoCaptured=1 and sourceApp populated
 * 5. Unsupported app notifications are silently ignored
 * 6. Onboarding page 5 sets hasCompletedOnboarding=true before dashboard navigation
 * ============================================================================
 */

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

  // 2. Run RecurringEngine check on startup to process any due recurring transactions
  try {
    final generatedCount = await RecurringEngine.processDueRecurring();
    debugPrint('Cold-start RecurringEngine processed $generatedCount transactions.');
  } catch (e) {
    debugPrint('Cold-start RecurringEngine error: $e');
  }

  // 3. Initialize NotificationReaderService early in app lifecycle
  try {
    NotificationReaderService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationReaderService init error: $e');
  }

  // 4. Initialize Workmanager for background recurring check
  try {
    Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      'recurring-check-task',
      'recurring-check',
      frequency: const Duration(hours: 6),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  } catch (e) {
    debugPrint('Workmanager initialization error: $e');
  }

  // 5. Run legacy category migration & default seeding
  await container.read(categoryEngineProvider).seedDefaults();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const YourBudgetManagerApp(),
    ),
  );
}
