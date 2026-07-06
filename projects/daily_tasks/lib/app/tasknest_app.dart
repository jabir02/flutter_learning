import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'app_settings_controller.dart';
import 'app_theme.dart';

class TaskNestApp extends ConsumerWidget {
  const TaskNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(appSettingsControllerProvider);

    return MaterialApp.router(
      title: 'TaskNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}