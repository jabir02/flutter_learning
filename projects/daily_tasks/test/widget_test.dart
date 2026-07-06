import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_tasks/main.dart';

void main() {
  testWidgets('TaskNest loads correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TaskNestAppTestWrapper());
    await tester.pumpAndSettle();

    expect(find.text('TaskNest'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Done'), findsWidgets);
  });

  testWidgets('User can add a task', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TaskNestAppTestWrapper());
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();

    expect(find.text('Add Task'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('task-title-field')),
      'Learn Flutter professionally',
    );

    await tester.enterText(
      find.byKey(const ValueKey('task-description-field')),
      'Build a polished portfolio app',
    );

    await tester.tap(find.byKey(const ValueKey('save-task-button')));
    await tester.pumpAndSettle();

    expect(find.text('TaskNest'), findsOneWidget);
    expect(find.text('Learn Flutter professionally'), findsOneWidget);
  });
}

class TaskNestAppTestWrapper extends StatelessWidget {
  const TaskNestAppTestWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const DailyTasksAppBootstrap();
  }
}