import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/dashboard/presentation/widgets/hero_balance_card.dart';
import 'package:your_budget_manager/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:your_budget_manager/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';
import 'package:your_budget_manager/routing/route_names.dart';

void main() {
  group('Phase 17: HeroBalanceCard & AddTransaction Type Selection', () {
    testWidgets('HeroBalanceCard renders Add Debit and Add Credit buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: HeroBalanceCard(totalBalance: 450000), // ₹4,500.00
          ),
        ),
      );

      expect(find.text("THIS MONTH'S SPEND"), findsOneWidget);
      expect(find.text('₹4,500.00'), findsOneWidget);
      expect(find.text('Add Debit'), findsOneWidget);
      expect(find.text('Add Credit'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('HeroBalanceCard buttons trigger navigation with correct query parameters', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      String? capturedRoute;
      Map<String, String>? capturedQueryParams;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: HeroBalanceCard(totalBalance: 50000),
            ),
          ),
          GoRoute(
            path: '/add-transaction',
            name: RouteNames.addTransaction,
            builder: (context, state) {
              capturedRoute = state.matchedLocation;
              capturedQueryParams = state.uri.queryParameters;
              return Scaffold(
                body: Text('AddTx: ${state.uri.queryParameters['type']}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Add Debit"
      await tester.tap(find.text('Add Debit'));
      await tester.pumpAndSettle();

      expect(capturedRoute, equals('/add-transaction'));
      expect(capturedQueryParams?['type'], equals('debit'));
      expect(find.text('AddTx: debit'), findsOneWidget);

      // Go back
      router.go('/');
      await tester.pumpAndSettle();

      // Tap "Add Credit"
      await tester.tap(find.text('Add Credit'));
      await tester.pumpAndSettle();

      expect(capturedRoute, equals('/add-transaction'));
      expect(capturedQueryParams?['type'], equals('credit'));
      expect(find.text('AddTx: credit'), findsOneWidget);
    });

    testWidgets('AddTransactionScreen initializes with Income when initialType is income', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late AddTransactionController controller;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesStreamProvider.overrideWith((ref) => Stream.value([
              Category(
                id: 'cat_salary',
                name: 'Salary',
                icon: 'income',
                color: 0xFF00FF00,
                isDefault: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
            ])),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              controller = ref.watch(addTransactionControllerProvider.notifier);
              return MaterialApp(
                theme: AppTheme.darkTheme,
                home: const AddTransactionScreen(
                  initialType: TransactionType.income,
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Confirm AddTransactionScreen rendered
      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Save Income'), findsOneWidget);
    });

    testWidgets('AddTransactionScreen initializes with Expense when initialType is expense', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesStreamProvider.overrideWith((ref) => Stream.value([
              Category(
                id: 'cat_food',
                name: 'Food',
                icon: 'food',
                color: 0xFFFF0000,
                isDefault: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
            ])),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const AddTransactionScreen(
              initialType: TransactionType.expense,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Save Expense'), findsOneWidget);
    });
  });
}
