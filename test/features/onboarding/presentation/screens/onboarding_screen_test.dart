import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_budget_manager/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders PrivacyPromisePage first', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    
    // Privacy promise page text
    expect(find.text('Your money is yours.'), findsOneWidget);
    
    // Tap continue to go to second page
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    
    // Feature Highlight page text
    expect(find.text('Features designed for you'), findsOneWidget);
  });
}
