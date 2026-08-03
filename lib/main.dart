import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/database_providers.dart';
import 'database/health/database_health_check.dart';
import 'engines/category/category_engine_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
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

