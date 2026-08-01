import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const YourBudgetManagerApp());
    expect(find.text('Your Budget Manager'), findsOneWidget);
  });
}
