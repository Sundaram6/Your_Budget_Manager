import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/providers/database_providers.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/budget/budget_engine.dart';
import 'package:your_budget_manager/engines/budget/budget_engine_provider.dart';
import 'package:your_budget_manager/engines/budget/models/budget_progress.dart';
import 'package:your_budget_manager/engines/budget/models/daily_allowance.dart';
import 'package:your_budget_manager/features/budgets/domain/repositories/budget_repository.dart';
import 'package:your_budget_manager/features/budgets/presentation/screens/budget_settings_screen.dart';

class FakeBudgetRepository implements BudgetRepository {
  final Budget? budget;
  FakeBudgetRepository({this.budget});

  @override
  Future<Budget?> getOverallBudget(int month, int year) async => budget;

  @override
  Future<Budget?> getCategoryBudget(String categoryId, int month, int year) async => null;

  @override
  Future<List<Budget>> getBudgetsForMonth(int month, int year) async => budget != null ? [budget!] : [];

  @override
  Future<void> setBudget(Budget budget) async {}

  @override
  Future<int> deleteBudget(Budget budget) async => 1;

  @override
  Future<void> deleteOverallBudget(int month, int year) async {}

  @override
  Future<void> insertBudget(Budget budget) async {}

  @override
  Future<void> updateBudget(Budget budget) async {}

  @override
  Stream<List<Budget>> watchAllBudgets() => Stream.value(budget != null ? [budget!] : []);
}

class FakeBudgetEngine implements BudgetEngine {
  final BudgetProgress progress;
  final Budget? budget;
  FakeBudgetEngine({required this.progress, this.budget});

  @override
  Future<BudgetProgress?> calculateBudgetProgress({int? month, int? year, DateTime? date}) async => progress;

  @override
  Future<Budget?> getOverallBudget(int month, int year) async => budget;

  @override
  Future<int?> getRemainingBudget({int? month, int? year}) async => progress.remaining;

  @override
  Future<Budget> setMonthlyBudget({
    required int amountPaise,
    required int month,
    required int year,
    String? categoryId,
  }) async {
    return Budget(
      id: 'b1',
      name: 'Monthly Budget',
      type: 'monthly',
      month: month,
      year: year,
      amount: amountPaise,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> deleteMonthlyBudget({required int month, required int year}) async {}

  @override
  Future<DailyAllowance?> calculateDailyAllowance({DateTime? date}) async => null;

  @override
  Future<int> getUpcomingRecurringSpend({int? month, int? year, DateTime? date}) async => progress.committedRecurring;

  @override
  Future<int> getCommittedSavings({String? budgetId, DateTime? date}) async => progress.committedSavings;

  @override
  Future<void> handleMonthRollover({DateTime? date}) async {}
}

void main() {
  group('Phase 18: BudgetSettingsScreen Render Overflow Tests', () {
    final now = DateTime.now();

    final testBudget = Budget(
      id: 'budget_1',
      name: 'Monthly Budget',
      type: 'monthly',
      month: now.month,
      year: now.year,
      amount: 10000000, // ₹1,00,000.00
      createdAt: now.millisecondsSinceEpoch,
    );

    final overCommittedProgress = BudgetProgress(
      limit: 10000000, // ₹1,00,000.00
      spent: 9000000, // ₹90,000.00
      committedRecurring: 5000000, // ₹50,000.00
      committedSavings: 4500000, // ₹45,000.00
      totalCommitted: 18500000, // ₹1,85,000.00
      remaining: -8500000, // -₹85,000.00 (Over-committed by ₹85,000.00)
      percentage: 1.85,
      isOverBudget: true,
    );

    final extremeProgress = BudgetProgress(
      limit: 5000000000, // ₹5,00,00,000.00
      spent: 4500000000, // ₹4,50,00,000.00
      committedRecurring: 2500000000, // ₹2,50,00,000.00
      committedSavings: 1500000000, // ₹1,50,00,000.00
      totalCommitted: 8500000000, // ₹8,50,00,000.00
      remaining: -3500000000, // -₹3,50,00,000.00
      percentage: 1.70,
      isOverBudget: true,
    );

    for (final width in [320.0, 360.0, 411.0]) {
      testWidgets('renders large over-committed values without overflow at width $width in Dark Theme', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        FlutterErrorDetails? caughtError;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          caughtError = details;
          originalOnError?.call(details);
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository(budget: testBudget)),
              budgetEngineProvider.overrideWithValue(FakeBudgetEngine(progress: overCommittedProgress, budget: testBudget)),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const BudgetSettingsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        FlutterError.onError = originalOnError;

        // Check widgets exist
        expect(find.textContaining('Budget'), findsWidgets);
        expect(find.text('Spent: ₹90,000.00'), findsOneWidget);
        expect(find.text('Recurring: ₹50,000.00'), findsOneWidget);
        expect(find.text('Savings: ₹45,000.00'), findsOneWidget);
        expect(find.text('Total Committed'), findsOneWidget);
        expect(find.text('₹1,85,000.00'), findsOneWidget);
        expect(find.text('Over-committed by ₹85,000.00'), findsOneWidget);

        // Verify zero overflow exceptions
        expect(caughtError, isNull);
      });

      testWidgets('renders within-budget values without overflow at width $width in Light Theme', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        FlutterErrorDetails? caughtError;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          caughtError = details;
          originalOnError?.call(details);
        };

        final withinBudgetProgress = BudgetProgress(
          limit: 15000000, // ₹1,50,000.00
          spent: 4000000, // ₹40,000.00
          committedRecurring: 3000000, // ₹30,000.00
          committedSavings: 2000000, // ₹20,000.00
          totalCommitted: 9000000, // ₹90,000.00
          remaining: 6000000, // ₹60,000.00
          percentage: 0.60,
          isOverBudget: false,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository(budget: testBudget)),
              budgetEngineProvider.overrideWithValue(FakeBudgetEngine(progress: withinBudgetProgress, budget: testBudget)),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const BudgetSettingsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        FlutterError.onError = originalOnError;

        expect(find.text('Total Committed'), findsOneWidget);
        expect(find.text('₹90,000.00'), findsOneWidget);
        expect(find.text('Remaining: ₹60,000.00'), findsOneWidget);

        expect(caughtError, isNull);
      });

      testWidgets('renders extreme 8-figure values without overflow at width $width in Dark Theme', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        FlutterErrorDetails? caughtError;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          caughtError = details;
          originalOnError?.call(details);
        };

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository(budget: testBudget)),
              budgetEngineProvider.overrideWithValue(FakeBudgetEngine(progress: extremeProgress, budget: testBudget)),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const BudgetSettingsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        FlutterError.onError = originalOnError;

        expect(find.text('Total Committed'), findsOneWidget);
        expect(find.text('₹8,50,00,000.00'), findsOneWidget);
        expect(find.text('Over-committed by ₹3,50,00,000.00'), findsOneWidget);

        expect(caughtError, isNull);
      });
    }
  });
}
