import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums.dart';
import '../core/providers/initial_route_provider.dart';
import '../core/security/app_lock_controller.dart';
import '../core/security/pin_service.dart';
import '../core/theme/app_animation.dart';
import '../core/widgets/layout/main_navigation_shell.dart';
import '../features/auth/presentation/screens/pin_lock_screen.dart';
import '../features/auth/presentation/screens/pin_setup_screen.dart';
import '../features/backup/presentation/screens/backup_screen.dart';
import '../features/budgets/presentation/screens/budget_detail_screen.dart';
import '../features/budgets/presentation/screens/budget_settings_screen.dart';
import '../features/categories/presentation/screens/category_management_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/intelligence/presentation/screens/insights_screen.dart';
import '../features/merchant_detection/presentation/screens/pending_transactions_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/savings/presentation/screens/add_savings_goal_screen.dart';
import '../features/savings/presentation/screens/savings_goal_detail_screen.dart';
import '../features/savings/presentation/screens/savings_goals_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/appearance_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/sms_settings_screen.dart';
import '../features/transactions/domain/entities/transaction.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../screens/recurring/create_recurring_screen.dart';
import '../screens/recurring/recurring_list_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/pin_security_screen.dart';
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

/// Builds a standardized page transition that respects reduced-motion accessibility settings.
Page<dynamic> _buildAppPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final isReduced = AppAnimation.isReducedMotion(context);
  if (isReduced) {
    return NoTransitionPage(
      key: state.pageKey,
      name: state.name,
      child: child,
    );
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: AppAnimation.durationMedium,
    reverseTransitionDuration: AppAnimation.durationNormal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppAnimation.curveStandard,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.03),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final initialLocation = ref.watch(initialRouteProvider);
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: notifier,
    // ── REDIRECT: PIN lock only. Onboarding is NOT guarded here. ──────────
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
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
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/pin-setup',
        name: RouteNames.pinSetup,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const PinSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/pin-lock',
        name: RouteNames.pinLock,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const PinLockScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/insights',
            name: RouteNames.insights,
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const InsightsScreen(),
            ),
          ),
          GoRoute(
            path: '/',
            name: RouteNames.dashboard,
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/add-transaction',
            name: RouteNames.addTransaction,
            pageBuilder: (context, state) {
              final typeParam = state.uri.queryParameters['type'];
              final initialType = (typeParam == 'income' || typeParam == 'credit')
                  ? TransactionType.income
                  : ((typeParam == 'expense' || typeParam == 'debit')
                      ? TransactionType.expense
                      : null);
              final extraTx = state.extra is Transaction ? state.extra as Transaction : null;
              return _buildAppPage(
                context: context,
                state: state,
                child: AddTransactionScreen(
                  initialTransaction: extraTx,
                  initialType: initialType,
                ),
              );
            },
          ),
          GoRoute(
            path: '/transactions',
            name: RouteNames.transactionList,
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const TransactionListScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: RouteNames.settings,
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/budgets',
            name: RouteNames.budgets,
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const BudgetSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/budgets/:id',
            name: RouteNames.budgetDetail,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildAppPage(
                context: context,
                state: state,
                child: BudgetDetailScreen(budgetId: id),
              );
            },
          ),
          GoRoute(
            path: '/recurring',
            name: RouteNames.recurring,
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const RecurringListScreen(),
            ),
          ),
          GoRoute(
            path: '/create-recurring',
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const CreateRecurringScreen(),
            ),
          ),
          GoRoute(
            path: '/backup',
            name: RouteNames.backup,
            pageBuilder: (context, state) => _buildAppPage(
              context: context,
              state: state,
              child: const BackupScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/sms-consent',
        name: RouteNames.smsConsent,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const PendingTransactionsScreen(),
        ),
      ),
      GoRoute(
        path: '/sms-settings',
        name: RouteNames.smsSettings,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const SmsSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/notification-settings',
        name: RouteNames.notificationSettings,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const NotificationSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/security',
        name: RouteNames.security,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const PinSecurityScreen(),
        ),
      ),
      GoRoute(
        path: '/savings',
        name: RouteNames.savingsGoals,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const SavingsGoalsScreen(),
        ),
      ),
      GoRoute(
        path: '/savings-goals',
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const SavingsGoalsScreen(),
        ),
      ),
      GoRoute(
        path: '/savings/add',
        name: RouteNames.addSavingsGoal,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const AddSavingsGoalScreen(),
        ),
      ),
      GoRoute(
        path: '/savings-goals/add',
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const AddSavingsGoalScreen(),
        ),
      ),
      GoRoute(
        path: '/savings/:id',
        name: RouteNames.savingsGoalDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildAppPage(
            context: context,
            state: state,
            child: SavingsGoalDetailScreen(id: id),
          );
        },
      ),
      GoRoute(
        path: '/savings-goals/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildAppPage(
            context: context,
            state: state,
            child: SavingsGoalDetailScreen(id: id),
          );
        },
      ),
      GoRoute(
        path: '/categories',
        name: RouteNames.categories,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const CategoryManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/appearance',
        name: RouteNames.appearance,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const AppearanceScreen(),
        ),
      ),
      GoRoute(
        path: '/about',
        name: RouteNames.about,
        pageBuilder: (context, state) => _buildAppPage(
          context: context,
          state: state,
          child: const AboutScreen(),
        ),
      ),
    ],
  );
}
