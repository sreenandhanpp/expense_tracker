import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/app/app.dart';

void main() {
  testWidgets('ExpenseTrackerApp launches and displays Home title', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Total Spending'), findsOneWidget);
  });
}
