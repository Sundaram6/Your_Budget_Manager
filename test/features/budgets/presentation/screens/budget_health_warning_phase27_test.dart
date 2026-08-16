import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/providers/database_providers.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine_provider.dart';
import 'package:your_budget_manager/engines/budget/budget_engine.dart';
import 'package:your_budget_manager/engines/budget/budget_engine_provider.dart';
import 'package:your_budget_manager/engines/budget/models/budget_progress.dart';
import 'package:your_budget_manager/engines/budget/models/daily_allowance.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine_provider.dart';
import 'package:your_budget_manager/engines/intelligence/models/ai_insight.dart';
import 'package:your_budget_manager/features/budgets/domain/repositories/budget_repository.dart';
import 'package:your_budget_manager/features/budgets/presentation/screens/budget_settings_screen.dart';
import 'package:your_budget_manager/features/intelligence/presentation/screens/insights_screen.dart';

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

class MockIntelligenceEngine extends Mock implements IntelligenceEngine {}
class MockAnalyticsEngine extends Mock implements AnalyticsEngine {}

void main() {
  late MockIntelligenceEngine mockIntelligenceEngine;
  late MockAnalyticsEngine mockAnalyticsEngine;

  setUp(() {
    mockIntelligenceEngine = MockIntelligenceEngine();
    mockAnalyticsEngine = MockAnalyticsEngine();
  });

  group('Phase 27: Budget Health Score & Survival Mode Warning Widget Tests', () {
    testWidgets('BudgetSettingsScreen displays Survival Mode Warning Card when over budget (Dark Theme)', (WidgetTester tester) async {
      final now = DateTime.now();
      final overBudget = Budget(
        id: 'b1',
        name: 'Overall Monthly Budget',
        amount: 1000000, // ₹10,000 in paise
        month: now.month,
        year: now.year,
        createdAt: now.millisecondsSinceEpoch,
        type: 'monthly',
      );

      const progress = BudgetProgress(
        spent: 1250000, // ₹12,500
        limit: 1000000, // ₹10,000
        percentage: 1.25,
        isOverBudget: true,
        committedRecurring: 0,
        committedSavings: 0,
        totalCommitted: 1250000,
        remaining: -250000, // -₹2,500
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository(budget: overBudget)),
            budgetEngineProvider.overrideWithValue(FakeBudgetEngine(progress: progress, budget: overBudget)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const BudgetSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Over-committed progress banner
      expect(find.textContaining('Over-committed by ₹2,500'), findsOneWidget);

      // Verify Survival Mode Tip Card
      expect(find.text('🚨 Survival Mode Active'), findsOneWidget);
      expect(find.textContaining("You've exceeded your budget by ₹2,500"), findsOneWidget);
      expect(find.textContaining('Freeze non-essential spending'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('BudgetSettingsScreen displays Survival Mode Warning Card when over budget (Light Theme)', (WidgetTester tester) async {
      final now = DateTime.now();
      final overBudget = Budget(
        id: 'b1',
        name: 'Overall Monthly Budget',
        amount: 1000000, // ₹10,000 in paise
        month: now.month,
        year: now.year,
        createdAt: now.millisecondsSinceEpoch,
        type: 'monthly',
      );

      const progress = BudgetProgress(
        spent: 1500000, // ₹15,000
        limit: 1000000, // ₹10,000
        percentage: 1.5,
        isOverBudget: true,
        committedRecurring: 0,
        committedSavings: 0,
        totalCommitted: 1500000,
        remaining: -500000, // -₹5,000
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetRepositoryProvider.overrideWithValue(FakeBudgetRepository(budget: overBudget)),
            budgetEngineProvider.overrideWithValue(FakeBudgetEngine(progress: progress, budget: overBudget)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const BudgetSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Over-committed by ₹5,000'), findsOneWidget);
      expect(find.text('🚨 Survival Mode Active'), findsOneWidget);
      expect(find.textContaining("You've exceeded your budget by ₹5,000"), findsOneWidget);
    });

    testWidgets('InsightsScreen renders Critical Deficit / Negative Health Score & Survival Mode Banner (Dark Theme)', (WidgetTester tester) async {
      when(() => mockIntelligenceEngine.calculateBudgetHealthScore(date: any(named: 'date'))).thenAnswer((_) async => -25);
      when(() => mockIntelligenceEngine.generateInsights()).thenAnswer((_) async => [
        AiInsight(
          id: 'survival_mode_tip',
          title: '🚨 Survival Mode Active',
          description: "Survival Mode: You've exceeded your budget by ₹3,500. Freeze all discretionary spending.",
          type: InsightType.warning,
          generatedAt: DateTime.now(),
          priority: -1,
        ),
      ]);
      when(() => mockAnalyticsEngine.getCategoryBreakdown(any(), any())).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            intelligenceEngineProvider.overrideWithValue(mockIntelligenceEngine),
            analyticsEngineProvider.overrideWithValue(mockAnalyticsEngine),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const InsightsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to AI Insights tab
      await tester.tap(find.text('AI Insights'));
      await tester.pumpAndSettle();

      // Verify Negative Health Score is rendered
      expect(find.text('-25'), findsOneWidget);
      expect(find.text('Financial Health'), findsOneWidget);
      expect(find.textContaining('Critical: Budget severely exceeded!'), findsOneWidget);
      expect(find.text('🚨 Survival Mode Active'), findsWidgets);
      expect(find.textContaining("You've exceeded your budget! Freeze non-essential expenses"), findsOneWidget);
    });

    testWidgets('InsightsScreen renders Over-Budget Warning state when health score is in 0..49 range (Light Theme)', (WidgetTester tester) async {
      when(() => mockIntelligenceEngine.calculateBudgetHealthScore(date: any(named: 'date'))).thenAnswer((_) async => 20);
      when(() => mockIntelligenceEngine.generateInsights()).thenAnswer((_) async => [
        AiInsight(
          id: 'survival_mode_tip',
          title: '🚨 Survival Mode Active',
          description: "Survival Mode: You've exceeded your budget by ₹1,500. Freeze all discretionary spending.",
          type: InsightType.warning,
          generatedAt: DateTime.now(),
          priority: -1,
        ),
      ]);
      when(() => mockAnalyticsEngine.getCategoryBreakdown(any(), any())).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            intelligenceEngineProvider.overrideWithValue(mockIntelligenceEngine),
            analyticsEngineProvider.overrideWithValue(mockAnalyticsEngine),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const InsightsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to AI Insights tab
      await tester.tap(find.text('AI Insights'));
      await tester.pumpAndSettle();

      expect(find.text('20'), findsOneWidget);
      expect(find.textContaining("You've exceeded your budget! Action required to balance spending."), findsOneWidget);
      expect(find.text('🚨 Survival Mode Active'), findsWidgets);
    });
  });
}
