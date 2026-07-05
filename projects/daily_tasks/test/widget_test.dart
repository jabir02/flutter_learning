import 'package:flutter_test/flutter_test.dart';

import 'package:daily_tasks/main.dart';

void main() {
  testWidgets('Daily Tasks app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyTasksApp());

    expect(find.text('Daily Tasks'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
  });
}