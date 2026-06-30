import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DailyTasksApp());
}

class DailyTasksApp extends StatelessWidget {
  const DailyTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}