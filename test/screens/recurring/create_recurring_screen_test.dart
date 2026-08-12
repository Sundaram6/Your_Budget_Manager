import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart'
    show categoriesStreamProvider;
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

  // CategoryPicker is a ConsumerWidget that watches a live Drift StreamProvider.
  // A live stream keeps emitting events preventing pumpAndSettle from ever
  // settling. Override it with a static empty-list stream that completes after
  // one emission so the widget tree can settle normally.
  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        categoriesStreamProvider.overrideWith(
          (ref) => Stream.value(const []),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child,
      ),
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
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Save Recurring'), findsOneWidget);
  });

  testWidgets('CreateRecurringScreen validates empty input fields on save', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestableWidget(const CreateRecurringScreen()));
    await tester.pumpAndSettle();

    final saveButton = find.text('Save Recurring');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid amount'), findsOneWidget);
  });

  testWidgets('CreateRecurringScreen creates recurring transaction successfully with all fields', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildTestableWidget(const CreateRecurringScreen()));
    await tester.pumpAndSettle();

    // Enter title
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'Spotify Family');
    await tester.pumpAndSettle();

    // Enter amount using keypad buttons '1', '7', '9'
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('9'));
    await tester.pumpAndSettle();

    final saveButton = find.text('Save Recurring');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final saved = await db.customSelect('SELECT * FROM recurring_transactions').get();
    expect(saved.length, equals(1));
    
    final data = saved.first.data;
    expect(data['title'], equals('Spotify Family'));
    expect(data['amount_paise'], equals(17900));
    expect(data['type'], equals('expense'));
    expect(data['frequency'], equals('monthly'));
  });
}
