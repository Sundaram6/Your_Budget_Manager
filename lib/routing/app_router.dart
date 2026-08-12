import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/providers/initial_route_provider.dart';
import '../core/security/app_lock_controller.dart';
import '../core/security/pin_service.dart';
import '../features/auth/presentation/screens/pin_lock_screen.dart';
import '../features/auth/presentation/screens/pin_setup_screen.dart';
import '../features/backup/presentation/screens/backup_screen.dart';
import '../features/budgets/presentation/screens/budget_detail_screen.dart';
import '../features/budgets/presentation/screens/budget_settings_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/intelligence/presentation/screens/insights_screen.dart';
import '../features/merchant_detection/presentation/screens/pending_transactions_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../screens/recurring/create_recurring_screen.dart';
import '../screens/recurring/recurring_list_screen.dart';
import '../features/savings/presentation/screens/add_savings_goal_screen.dart';
import '../features/savings/presentation/screens/savings_goal_detail_screen.dart';
import '../features/savings/presentation/screens/savings_goals_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/sms_settings_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../core/widgets/layout/main_navigation_shell.dart';
import 'route_names.dart';

part 'app_router.g.dart';

// Provides shared preferences to the router (used by PIN lock redirect only)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<bool>(
      appLockControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
  final Ref ref;
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

@riverpod
GoRouter appRouter(Ref ref) {
  // initialLocation is set synchronously in main.dart before the app starts.
  // The router NEVER re-evaluates onboarding state reactively — that was the
  // source of the infinite redirect loop.
  final initialLocation = ref.watch(initialRouteProvider);
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: notifier,
    // ── REDIRECT: PIN lock only. Onboarding is NOT guarded here. ──────────
    redirect: (context, state) async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final isPinSetupComplete =
          (prefs.getBool('pin_setup_complete') ?? prefs.getBool('pinSetupComplete')) ?? false;
      final hasSkippedPin =
          (prefs.getBool('hasSkippedPinSetup') ?? prefs.getBool('has_skipped_pin')) ?? false;

      final pinService = ref.read(pinServiceProvider);
      final hasPin = await pinService.hasPin();

      final loc = state.matchedLocation;
      final isLockPath = loc == '/pin-lock';
      final isSetupPath = loc == '/pin-setup';
      // Onboarding path must pass through without any redirect interference
      final isOnboardingPath = loc == '/onboarding';

      if (isOnboardingPath) return null;

      if (!isPinSetupComplete && !hasSkippedPin) {
        if (isSetupPath) return null;
        return '/pin-setup';
      }

      final useBiometric = prefs.getBool('pref_use_biometric') ?? false;
      final isSecurityActive = hasPin || useBiometric;
      final isLocked = ref.read(appLockControllerProvider);

      if (isSecurityActive && isLocked) {
        if (isLockPath) return null;
        return '/pin-lock';
      }

      if (isLockPath || isSetupPath) {
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
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/',
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/add-transaction',
            name: RouteNames.addTransaction,
            builder: (context, state) => const AddTransactionScreen(),
          ),
          GoRoute(
            path: '/transactions',
            name: RouteNames.transactionList,
            builder: (context, state) => const TransactionListScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/budgets',
            name: RouteNames.budgets,
            builder: (context, state) => const BudgetSettingsScreen(),
          ),
          GoRoute(
            path: '/budgets/:id',
            name: RouteNames.budgetDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BudgetDetailScreen(budgetId: id);
            },
          ),
          GoRoute(
            path: '/recurring',
            name: RouteNames.recurring,
            builder: (context, state) => const RecurringListScreen(),
          ),
          GoRoute(
            path: '/create-recurring',
            builder: (context, state) => const CreateRecurringScreen(),
          ),
          GoRoute(
            path: '/backup',
            name: RouteNames.backup,
            builder: (context, state) => const BackupScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/sms-consent',
        name: RouteNames.smsConsent,
        builder: (context, state) => const PendingTransactionsScreen(),
      ),
      GoRoute(
        path: '/sms-settings',
        name: RouteNames.smsSettings,
        builder: (context, state) => const SmsSettingsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        name: RouteNames.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/savings',
        name: RouteNames.savingsGoals,
        builder: (context, state) => const SavingsGoalsScreen(),
      ),
      GoRoute(
        path: '/savings-goals',
        builder: (context, state) => const SavingsGoalsScreen(),
      ),
      GoRoute(
        path: '/savings/add',
        name: RouteNames.addSavingsGoal,
        builder: (context, state) => const AddSavingsGoalScreen(),
      ),
      GoRoute(
        path: '/savings-goals/add',
        builder: (context, state) => const AddSavingsGoalScreen(),
      ),
      GoRoute(
        path: '/savings/:id',
        name: RouteNames.savingsGoalDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SavingsGoalDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/savings-goals/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SavingsGoalDetailScreen(id: id);
        },
      ),
    ],
  );
}
