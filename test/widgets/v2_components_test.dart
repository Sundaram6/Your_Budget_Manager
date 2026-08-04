import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/core/theme/app_custom_tokens.dart';
import 'package:your_budget_manager/core/widgets/charts/progress_donut_chart.dart';
import 'package:your_budget_manager/core/widgets/cards/status_tile.dart';

void main() {
  Widget createTestWidget(Widget child, ThemeData theme) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('V2 Reusable Components Test', () {
    testWidgets('ProgressDonutChart renders correctly with data', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ProgressDonutChart(
            data: {'Rent': 500.0, 'Food': 300.0},
          ),
          AppTheme.lightTheme,
        ),
      );

      // Verify PieChart is rendered (part of fl_chart)
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('StatusTile uses correct tint based on theme', (WidgetTester tester) async {
      const statusColor = Colors.green;
      
      await tester.pumpWidget(
        createTestWidget(
          const StatusTile(
            icon: Icons.check,
            title: 'Test',
            subtitle: 'Subtitle',
            statusColor: statusColor,
          ),
          AppTheme.darkTheme,
        ),
      );

      // We verify it renders without errors and finds the texts
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      
      // Get the Material widget to inspect the color
      final materialFinder = find.descendant(
        of: find.byType(StatusTile),
        matching: find.byType(Material),
      ).first;
      
      final material = tester.widget<Material>(materialFinder);
      
      // Wait, there might be multiple materials, but the first one should be our tile container.
      expect(material.color, isNotNull);
      
      // Replicate the alpha blend logic to verify correctness
      final tokens = AppTheme.darkTheme.extension<AppCustomTokens>()!;
      final expectedColor = Color.alphaBlend(
        statusColor.withOpacity(tokens.statusTileTintOpacity), 
        AppTheme.darkTheme.colorScheme.surface
      );
      
      expect(material.color, equals(expectedColor));
    });
  });
}
