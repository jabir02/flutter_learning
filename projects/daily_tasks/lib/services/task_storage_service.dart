import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'daily_tasks';

  Future<List<Task>> loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> savedTaskStrings = prefs.getStringList(_tasksKey) ?? [];

    final List<Task> loadedTasks = [];

    for (final String taskString in savedTaskStrings) {
      try {
        final Map<String, dynamic> taskMap =
            jsonDecode(taskString) as Map<String, dynamic>;

        loadedTasks.add(Task.fromJson(taskMap));
      } catch (_) {
        continue;
      }
    }

    return loadedTasks;
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> taskStrings = tasks.map((task) {
      return jsonEncode(task.toJson());
    }).toList();

    await prefs.setStringList(_tasksKey, taskStrings);
  }
}