import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders Welcome page first and navigates through steps', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    
    // Page 1: Welcome title & button
    expect(find.text('Take control of your money'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    
    // Tap Get Started to go to Page 2
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    
    // Page 2: Monthly Budget
    expect(find.text('What\'s your monthly budget?'), findsOneWidget);
  });
}
