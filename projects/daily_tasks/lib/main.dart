import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/tasknest_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const DailyTasksAppBootstrap());
}

class DailyTasksAppBootstrap extends StatelessWidget {
  const DailyTasksAppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: TaskNestApp(),
    );
  }
}