import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_tasks/main.dart';

void main() {
  testWidgets('Daily Tasks app loads correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DailyTasksApp());
    await tester.pumpAndSettle();

    expect(find.text('Daily Tasks'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
  });

  testWidgets('User can add a task', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DailyTasksApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'Learn Flutter');
    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    expect(find.text('Learn Flutter'), findsOneWidget);
  });
}