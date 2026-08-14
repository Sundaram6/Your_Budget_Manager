import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/providers/database_providers.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/database/app_database.dart' hide Category;
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine_provider.dart';
import 'package:your_budget_manager/features/budgets/domain/repositories/budget_repository.dart';
import 'package:your_budget_manager/features/budgets/presentation/screens/budget_settings_screen.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/savings/presentation/screens/add_savings_goal_screen.dart';
import 'package:your_budget_manager/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';
import 'package:your_budget_manager/screens/recurring/create_recurring_screen.dart';
import 'package:your_budget_manager/core/widgets/inputs/numeric_keypad.dart';

class FakeBudgetRepository implements BudgetRepository {
  @override
  Future<Budget?> getOverallBudget(int month, int year) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAnalyticsEngine implements AnalyticsEngine {
  @override
  Future<int> getMonthlyTotal(int year, int month) async => 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase testDb;

  setUp(() {
    testDb = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(testDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(testDb),
        budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository()),
        analyticsEngineProvider.overrideWithValue(FakeAnalyticsEngine()),
        categoriesStreamProvider.overrideWith((ref) => Stream.value([
              Category(
                id: 'cat_utilities',
                name: 'Utilities',
                icon: 'receipt',
                color: 0xFF2196F3,
                isDefault: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              Category(
                id: 'cat_food',
                name: 'Food',
                icon: 'restaurant',
                color: 0xFF4CAF50,
                isDefault: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ])),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  group('Phase 14: On-Screen Keyboard Covering Forms & Keypad Insets', () {
    testWidgets('AddTransactionScreen hides NumericKeypad and prevents overflow when keyboard opens',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 2.0; // Logical size: 400x640
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(buildTestApp(const AddTransactionScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially, NumericKeypad is visible
      expect(find.byType(NumericKeypad), findsOneWidget);
      expect(find.text('Add a note (optional)'), findsOneWidget);

      // Simulate on-screen software keyboard opening (e.g. 300 logical px height)
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No RenderFlex overflow should occur, and NumericKeypad should collapse/hide
      expect(tester.takeException(), isNull);
      expect(find.byType(NumericKeypad), findsNothing);
      expect(find.text('Add a note (optional)'), findsOneWidget);

      // Close keyboard
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // NumericKeypad reappears
      expect(find.byType(NumericKeypad), findsOneWidget);
    });

    testWidgets('CreateRecurringScreen hides NumericKeypad and prevents overflow when keyboard opens',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 2.0; // Logical size: 400x640
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(buildTestApp(const CreateRecurringScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially, NumericKeypad is visible
      expect(find.byType(NumericKeypad), findsOneWidget);
      expect(find.text('Title (e.g. Netflix, Rent)'), findsOneWidget);

      // Simulate software keyboard opening
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No overflow, keypad hides, title field remains accessible
      expect(tester.takeException(), isNull);
      expect(find.byType(NumericKeypad), findsNothing);
      expect(find.text('Title (e.g. Netflix, Rent)'), findsOneWidget);

      // Close keyboard
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(NumericKeypad), findsOneWidget);
    });

    testWidgets('AddSavingsGoalScreen handles software keyboard without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 2.0; // Logical size: 400x640
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(buildTestApp(const AddSavingsGoalScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Goal Name'), findsOneWidget);

      // Open keyboard
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Goal Name'), findsOneWidget);

      // Close keyboard
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('BudgetSettingsScreen handles software keyboard without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 2.0; // Logical size: 400x640
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(buildTestApp(const BudgetSettingsScreen()));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Monthly Budget Amount'), findsOneWidget);

      // Open keyboard
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(tester.takeException(), isNull);
      expect(find.text('Monthly Budget Amount'), findsOneWidget);

      // Close keyboard
      tester.view.viewInsets = FakeViewPadding.zero;
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(tester.takeException(), isNull);
    });
  });
}
