import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/theme/app_theme.dart';
import 'engines/sms/sms_auto_tracker.dart';
import 'routing/app_router.dart';

class YourBudgetManagerApp extends ConsumerStatefulWidget {
  const YourBudgetManagerApp({super.key});

  @override
  ConsumerState<YourBudgetManagerApp> createState() => _YourBudgetManagerAppState();
}

class _YourBudgetManagerAppState extends ConsumerState<YourBudgetManagerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAutoTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkMissedSms();
    }
  }

  Future<void> _initAutoTracking() async {
    final status = await Permission.sms.status;
    if (status.isGranted) {
      final tracker = ref.read(smsAutoTrackerProvider);
      tracker.startForegroundTracking();
      _checkMissedSms();
    }
  }

  Future<void> _checkMissedSms() async {
    try {
      final tracker = ref.read(smsAutoTrackerProvider);
      final count = await tracker.processBackgroundQueue();
      
      if (count > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count new transactions auto-tracked from SMS'),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFFF5D395),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Your Budget Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
    );
  }
}
