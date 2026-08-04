import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/widgets/buttons/primary_button.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/repositories/recurring_repository.dart';
import 'package:your_budget_manager/screens/recurring/create_recurring_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(db);
    await DatabaseHealthCheck(db).run();
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('CreateRecurringScreen renders all form fields correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestableWidget(const CreateRecurringScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Add Recurring'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
    expect(find.text('Utilities & Bills'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('No End Date'), findsOneWidget);
    expect(find.text('Auto-add to budget without asking'), findsOneWidget);

    final buttonFinder = find.byType(PrimaryButton);
    await tester.ensureVisible(buttonFinder);
    expect(buttonFinder, findsOneWidget);
  });

  testWidgets('CreateRecurringScreen validates empty input fields on save', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestableWidget(const CreateRecurringScreen()));
    await tester.pumpAndSettle();

    final buttonFinder = find.byType(PrimaryButton);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
  });

  testWidgets('CreateRecurringScreen saves valid recurring transaction', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestableWidget(const CreateRecurringScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Spotify Family');
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '179');
    await tester.pumpAndSettle();

    final buttonFinder = find.byType(PrimaryButton);
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    final saved = await RecurringRepository.instance.watchAll().first;
    expect(saved.length, equals(1));
    expect(saved.first.title, equals('Spotify Family'));
    expect(saved.first.amountPaise, equals(17900));
    expect(saved.first.type, equals('expense'));
    expect(saved.first.frequency, equals('monthly'));
  });
}
