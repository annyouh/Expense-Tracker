import 'package:flutter_test/flutter_test.dart';
import 'package:expenseee/expense_tracker.dart';

void main() {
  testWidgets('Expense tracker smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpensoApp());
    expect(find.text('TRACKER'), findsOneWidget);
  });
}
