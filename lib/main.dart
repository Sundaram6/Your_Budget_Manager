import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'engines/category/category_engine_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  // Ensure default categories are seeded into DB on startup
  await container.read(categoryEngineProvider).seedDefaults();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const YourBudgetManagerApp(),
    ),
  );
}
