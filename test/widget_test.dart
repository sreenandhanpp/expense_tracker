import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/screens/login_screen.dart';

void main() {
  testWidgets('ExpenseTrackerApp launches and builds widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pump();
    expect(find.byType(ExpenseTrackerApp), findsOneWidget);
  });
}
