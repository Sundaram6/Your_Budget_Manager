import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:your_budget_manager/core/theme/app_animation.dart';

void main() {
  group('Phase 16: AppAnimation Tokens & Durations', () {
    test('standard animation tokens exist and have consistent progression', () {
      expect(AppAnimation.durationMicro.inMilliseconds, equals(100));
      expect(AppAnimation.durationFast.inMilliseconds, equals(150));
      expect(AppAnimation.durationNormal.inMilliseconds, equals(250));
      expect(AppAnimation.durationMedium.inMilliseconds, equals(300));
      expect(AppAnimation.durationSlow.inMilliseconds, equals(450));
      expect(AppAnimation.durationCinematic.inMilliseconds, equals(600));
      expect(AppAnimation.durationStaggerStep.inMilliseconds, equals(35));

      expect(AppAnimation.curveStandard, equals(Curves.easeOutCubic));
      expect(AppAnimation.curveEntrance, equals(Curves.easeOutQuad));
    });

    testWidgets('AppAnimation.isReducedMotion detects standard vs disabled animations', (tester) async {
      late bool normalMotion;
      late bool reducedMotionDisabled;
      late bool accessibleNav;

      // 1. Standard mode
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              normalMotion = AppAnimation.isReducedMotion(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(normalMotion, isFalse);

      // 2. Disabled animations (prefers-reduced-motion)
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                reducedMotionDisabled = AppAnimation.isReducedMotion(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(reducedMotionDisabled, isTrue);

      // 3. Accessible navigation
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                accessibleNav = AppAnimation.isReducedMotion(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(accessibleNav, isTrue);
    });

    testWidgets('animateEntrance renders safely in widget tree and animates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return const Text('Animated Card').animateEntrance(context, index: 1);
              },
            ),
          ),
        ),
      );

      expect(find.text('Animated Card'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Animated Card'), findsOneWidget);
    });

    testWidgets('animateEntrance returns raw widget with zero lag when reduced motion is enabled', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return const Text('Direct Card').animateEntrance(context, index: 2);
                },
              ),
            ),
          ),
        ),
      );

      // Should find the text immediately with zero animation delay
      expect(find.text('Direct Card'), findsOneWidget);
    });

    testWidgets('animateStaggered renders list of widgets cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    const Text('Item 1'),
                    const Text('Item 2'),
                    const Text('Item 3'),
                  ].animateStaggered(context),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('animateStaggered respects disableAnimations setting', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      const Text('Reduced Item 1'),
                      const Text('Reduced Item 2'),
                    ].animateStaggered(context),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Reduced Item 1'), findsOneWidget);
      expect(find.text('Reduced Item 2'), findsOneWidget);
    });
  });
}
