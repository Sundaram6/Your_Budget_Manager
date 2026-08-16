import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/providers/database_providers.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/core/widgets/charts/progress_donut_chart.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine_provider.dart';
import 'package:your_budget_manager/engines/analytics/models/analytics_models.dart';
import 'package:your_budget_manager/engines/analytics/providers/analytics_customization_provider.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine_provider.dart';
import 'package:your_budget_manager/features/analytics/presentation/widgets/category_filter_dialog.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/categories/domain/repositories/category_repository.dart';
import 'package:your_budget_manager/features/intelligence/presentation/screens/insights_screen.dart';
import 'package:your_budget_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';

class MockIntelligenceEngine extends Mock implements IntelligenceEngine {}
class MockAnalyticsEngine extends Mock implements AnalyticsEngine {}
class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockIntelligenceEngine mockIntelligenceEngine;
  late MockAnalyticsEngine mockAnalyticsEngine;
  late MockCategoryRepository mockCatRepo;
  late MockTransactionRepository mockTxRepo;

  final sampleBreakdown = [
    const CategoryBreakdown(
      categoryId: 'cat_food',
      categoryName: 'Food & Dining',
      color: 0xFF4CAF50,
      icon: 'restaurant',
      total: 500000, // ₹5,000
      percentage: 50.0,
    ),
    const CategoryBreakdown(
      categoryId: 'cat_shopping',
      categoryName: 'Shopping',
      color: 0xFF2196F3,
      icon: 'shopping_bag',
      total: 300000, // ₹3,000
      percentage: 30.0,
    ),
    const CategoryBreakdown(
      categoryId: 'cat_transport',
      categoryName: 'Transport',
      color: 0xFFFF9800,
      icon: 'directions_car',
      total: 200000, // ₹2,000
      percentage: 20.0,
    ),
  ];

  final sampleCategories = [
    const Category(id: 'cat_food', name: 'Food & Dining', color: 0xFF4CAF50, icon: 'restaurant'),
    const Category(id: 'cat_shopping', name: 'Shopping', color: 0xFF2196F3, icon: 'shopping_bag'),
    const Category(id: 'cat_transport', name: 'Transport', color: 0xFFFF9800, icon: 'directions_car'),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockIntelligenceEngine = MockIntelligenceEngine();
    mockAnalyticsEngine = MockAnalyticsEngine();
    mockCatRepo = MockCategoryRepository();
    mockTxRepo = MockTransactionRepository();

    when(() => mockIntelligenceEngine.calculateBudgetHealthScore(date: any(named: 'date')))
        .thenAnswer((_) async => 85);
    when(() => mockIntelligenceEngine.generateInsights())
        .thenAnswer((_) async => []);
    when(() => mockAnalyticsEngine.getCategoryBreakdown(any(), any(), hiddenCategoryIds: any(named: 'hiddenCategoryIds')))
        .thenAnswer((_) async => sampleBreakdown);
    when(() => mockCatRepo.getCategories())
        .thenAnswer((_) async => sampleCategories);
    when(() => mockTxRepo.watchTransactionsByDateRange(any(), any()))
        .thenAnswer((_) => Stream.value([]));
  });

  group('Phase 28: InsightsScreen Chart Interactivity & Customization Widget Tests', () {
    testWidgets('Renders interactive ProgressDonutChart and legend chips in Dark Theme', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            intelligenceEngineProvider.overrideWithValue(mockIntelligenceEngine),
            analyticsEngineProvider.overrideWithValue(mockAnalyticsEngine),
            categoryRepositoryProvider.overrideWithValue(mockCatRepo),
            transactionRepositoryProvider.overrideWithValue(mockTxRepo),
            categoriesStreamProvider.overrideWith((ref) => Stream.value(sampleCategories)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const InsightsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert Donut chart & legend chips render
      expect(find.byType(ProgressDonutChart), findsOneWidget);
      expect(find.text('Tap slice to view transactions'), findsOneWidget);
      expect(find.text('Customize'), findsOneWidget);
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Categories (tap to toggle)'), findsOneWidget);
    });

    testWidgets('Tapping a category legend chip toggles hidden state and updates style (Light Theme)', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            intelligenceEngineProvider.overrideWithValue(mockIntelligenceEngine),
            analyticsEngineProvider.overrideWithValue(mockAnalyticsEngine),
            categoryRepositoryProvider.overrideWithValue(mockCatRepo),
            transactionRepositoryProvider.overrideWithValue(mockTxRepo),
            categoriesStreamProvider.overrideWith((ref) => Stream.value(sampleCategories)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const InsightsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: all visible
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(3));
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Tap the Food & Dining legend chip to hide it
      await tester.tap(find.text('Food & Dining'));
      await tester.pumpAndSettle();

      // Assert visibility icon changes to visibility_off
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
    });

    testWidgets('Tapping Customize opens CategoryFilterDialog with checklist and Show All / Hide All (Dark Theme)', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            intelligenceEngineProvider.overrideWithValue(mockIntelligenceEngine),
            analyticsEngineProvider.overrideWithValue(mockAnalyticsEngine),
            categoryRepositoryProvider.overrideWithValue(mockCatRepo),
            transactionRepositoryProvider.overrideWithValue(mockTxRepo),
            categoriesStreamProvider.overrideWith((ref) => Stream.value(sampleCategories)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const InsightsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Customize button
      await tester.tap(find.text('Customize'));
      await tester.pumpAndSettle();

      // Assert CategoryFilterDialog is displayed
      expect(find.byType(CategoryFilterDialog), findsOneWidget);
      expect(find.text('Customize Categories'), findsOneWidget);
      expect(find.text('Show All'), findsOneWidget);
      expect(find.text('Hide All'), findsOneWidget);

      // Tap Done
      await tester.tap(find.byTooltip('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryFilterDialog), findsNothing);
    });

    testWidgets('All categories hidden displays clean empty state message', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          intelligenceEngineProvider.overrideWithValue(mockIntelligenceEngine),
          analyticsEngineProvider.overrideWithValue(mockAnalyticsEngine),
          categoryRepositoryProvider.overrideWithValue(mockCatRepo),
          transactionRepositoryProvider.overrideWithValue(mockTxRepo),
          categoriesStreamProvider.overrideWith((ref) => Stream.value(sampleCategories)),
        ],
      );

      // Hide all categories in provider
      container.read(analyticsHiddenCategoriesProvider.notifier).setHiddenCategories(
        {'cat_food', 'cat_shopping', 'cat_transport'},
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const InsightsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All categories are hidden'), findsOneWidget);
      expect(find.text('Tap a category chip below or customize to show data.'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);
    });
  });
}
