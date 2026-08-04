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
import '../features/recurring/presentation/screens/recurring_transactions_screen.dart';
import '../features/savings/presentation/screens/add_savings_goal_screen.dart';
import '../features/savings/presentation/screens/savings_goal_detail_screen.dart';
import '../features/savings/presentation/screens/savings_goals_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/sms_settings_screen.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

// Provides shared preferences to the router
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) => SharedPreferences.getInstance());

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final initialLocation = ref.watch(initialRouteProvider);
  final isLocked = ref.watch(appLockControllerProvider);
  
  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final isPinSetupComplete = (prefs.getBool('pin_setup_complete') ?? prefs.getBool('pinSetupComplete')) ?? false;
      final hasSkippedPin = (prefs.getBool('hasSkippedPinSetup') ?? prefs.getBool('has_skipped_pin')) ?? false;

      final pinService = ref.read(pinServiceProvider);
      final hasPin = await pinService.hasPin();

      final isLockPath = state.matchedLocation == '/pin-lock';
      final isSetupPath = state.matchedLocation == '/pin-setup';

      if (!isPinSetupComplete && !hasSkippedPin) {
        if (isSetupPath) return null;
        return '/pin-setup';
      }

      if (hasPin && isLocked) {
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
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return child;
        },
        routes: [
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
            builder: (context, state) => const RecurringTransactionsScreen(),
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
