import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/settings/screens/settings_screen.dart';
import '../features/tasks/screens/home_screen.dart';
import '../features/tasks/screens/task_details_screen.dart';
import '../features/tasks/screens/upsert_task_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/add',
        name: 'addTask',
        builder: (context, state) {
          return const UpsertTaskScreen();
        },
      ),
      GoRoute(
        path: '/task/:id',
        name: 'taskDetails',
        builder: (context, state) {
          final String taskId = state.pathParameters['id']!;

          return TaskDetailsScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/edit/:id',
        name: 'editTask',
        builder: (context, state) {
          final String taskId = state.pathParameters['id']!;

          return UpsertTaskScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) {
          return const SettingsScreen();
        },
      ),
    ],
  );
});