import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/database_providers.dart';
import 'core/providers/initial_route_provider.dart';
import 'database/health/database_health_check.dart';
import 'engines/category/category_engine_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = (prefs.getBool('hasCompletedOnboarding') ?? prefs.getBool('onboarding_complete')) ?? false;

  final container = ProviderContainer(
    overrides: [
      initialRouteProvider.overrideWithValue(
        hasCompletedOnboarding ? '/' : '/onboarding',
      ),
    ],
  );

  // 1. Run DatabaseHealthCheck safety net on every startup before any read/write
  final db = container.read(appDatabaseProvider);
  await DatabaseHealthCheck(db).run();

  // 2. Run legacy category migration & default seeding
  await container.read(categoryEngineProvider).seedDefaults();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const YourBudgetManagerApp(),
    ),
  );
}
