import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/core/widgets/layout/main_navigation_shell.dart';
import 'package:your_budget_manager/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:your_budget_manager/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/quick_add_fab.dart';
import 'package:your_budget_manager/routing/route_names.dart';

class FakeDashboardController extends DashboardController {
  final DashboardState mockState;
  FakeDashboardController(this.mockState);

  @override
  FutureOr<DashboardState> build() async {
    return mockState;
  }
}

GoRouter createTestRouter({
  void Function(String route)? onRoutePushed,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/insights',
            name: RouteNames.insights,
            builder: (context, state) => const Scaffold(body: Text('Insights Screen')),
          ),
          GoRoute(
            path: '/transactions',
            name: RouteNames.transactionList,
            builder: (context, state) => const Scaffold(body: Text('Transactions Screen')),
          ),
          GoRoute(
            path: '/budgets',
            name: RouteNames.budgets,
            builder: (context, state) => const Scaffold(body: Text('Budgets Screen')),
          ),
          GoRoute(
            path: '/add-transaction',
            name: RouteNames.addTransaction,
            builder: (context, state) {
              onRoutePushed?.call('/add-transaction');
              return const Scaffold(body: Text('Add Transaction Screen'));
            },
          ),
          GoRoute(
            path: '/create-recurring',
            builder: (context, state) {
              onRoutePushed?.call('/create-recurring');
              return const Scaffold(body: Text('Create Recurring Screen'));
            },
          ),
        ],
      ),
    ],
  );
}

void main() {
  group('Phase 19: Dashboard QuickAddFab Tests', () {
    const testState = DashboardState(
      monthlyTotal: 500000, // ₹5,000.00
      categoryBreakdown: [],
      budgetProgress: [],
      recentTransactions: [],
      insights: [],
      healthScore: 85,
    );

    testWidgets('QuickAddFab is visible and positioned above the bottom navigation bar on Home screen', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardControllerProvider.overrideWith(() => FakeDashboardController(testState)),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify QuickAddFab exists
      final fabFinder = find.byType(QuickAddFab);
      expect(fabFinder, findsOneWidget);

      // 2. Verify FAB is visible and not clipped
      final fabRect = tester.getRect(fabFinder);
      final navBarFinder = find.byType(MainNavigationShell);
      expect(navBarFinder, findsOneWidget);

      // Bottom of screen is 800.
      // The FAB must be above the bottom nav bar (fab bottom < 800 - 60).
      expect(fabRect.bottom, lessThan(800 - 60));
      expect(fabRect.right, closeTo(360 - 16, 5));
    });

    testWidgets('Tapping QuickAddFab opens bottom sheet with options', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardControllerProvider.overrideWith(() => FakeDashboardController(testState)),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the FAB
      await tester.tap(find.byType(QuickAddFab));
      await tester.pumpAndSettle();

      // Verify bottom sheet options appear
      expect(find.text('Create New'), findsOneWidget);
      expect(find.text('One-Time Transaction'), findsOneWidget);
      expect(find.text('Recurring Payment'), findsOneWidget);
      expect(find.text('Record a single expense or income'), findsOneWidget);
      expect(find.text('Rent, EMI, Netflix, SIP, Recharge...'), findsOneWidget);
    });

    testWidgets('BottomSheet options navigate to AddTransaction and CreateRecurring', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      String? pushedRoute;
      final router = createTestRouter(onRoutePushed: (route) => pushedRoute = route);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardControllerProvider.overrideWith(() => FakeDashboardController(testState)),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test Option 1: One-Time Transaction
      await tester.tap(find.byType(QuickAddFab));
      await tester.pumpAndSettle();

      await tester.tap(find.text('One-Time Transaction'));
      await tester.pumpAndSettle();

      expect(pushedRoute, '/add-transaction');
      expect(find.text('Add Transaction Screen'), findsOneWidget);

      // Return to Dashboard
      router.go('/');
      await tester.pumpAndSettle();

      // Test Option 2: Recurring Payment
      await tester.tap(find.byType(QuickAddFab));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recurring Payment'));
      await tester.pumpAndSettle();

      expect(pushedRoute, '/create-recurring');
      expect(find.text('Create Recurring Screen'), findsOneWidget);
    });

    testWidgets('FAB remains visible after switching tabs and returning to Home', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final router = createTestRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardControllerProvider.overrideWith(() => FakeDashboardController(testState)),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(QuickAddFab), findsOneWidget);

      // Switch to Insights tab
      await tester.tap(find.byIcon(Icons.pie_chart_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Insights Screen'), findsOneWidget);
      expect(find.byType(QuickAddFab), findsNothing);

      // Switch back to Home tab
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(QuickAddFab), findsOneWidget);

      // Verify FAB is tappable
      await tester.tap(find.byType(QuickAddFab));
      await tester.pumpAndSettle();
      expect(find.text('Create New'), findsOneWidget);
    });
  });
}
