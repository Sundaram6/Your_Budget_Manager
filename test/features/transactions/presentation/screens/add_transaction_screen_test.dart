import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/categories/domain/entities/category.dart';
import 'package:your_budget_manager/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:your_budget_manager/features/transactions/presentation/widgets/category_picker.dart';

void main() {
  testWidgets('AddTransactionScreen renders properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesStreamProvider.overrideWith((ref) => Stream.value([
            Category(
              id: '1',
              name: 'Food',
              icon: 'restaurant',
              color: 0xFF00FF00,
              isDefault: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          ])),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const AddTransactionScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
  });
}
