import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String tasksStorageKey = 'daily_tasks';

  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final List<String> savedTasks =
          prefs.getStringList(tasksStorageKey) ?? [];

      final List<Task> loadedTasks = savedTasks.map((taskString) {
        final Map<String, dynamic> taskMap =
            jsonDecode(taskString) as Map<String, dynamic>;

        return Task.fromJson(taskMap);
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        tasks = [];
        isLoading = false;
      });
    }
  }

  Future<void> saveTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> taskStrings = tasks.map((task) {
      return jsonEncode(task.toJson());
    }).toList();

    await prefs.setStringList(tasksStorageKey, taskStrings);
  }

  Future<void> openAddTaskScreen() async {
    final String? taskTitle = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    if (taskTitle == null) {
      return;
    }

    await addTask(taskTitle);
  }

  Future<void> addTask(String taskTitle) async {
    final Task newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: taskTitle,
    );

    setState(() {
      tasks.add(newTask);
    });

    await saveTasks();
  }

  Future<void> deleteTask(int index) async {
    setState(() {
      tasks.removeAt(index);
    });

    await saveTasks();
  }

  Future<void> toggleTask(int index) async {
    final Task oldTask = tasks[index];

    final Task updatedTask = oldTask.copyWith(
      isCompleted: !oldTask.isCompleted,
    );

    setState(() {
      tasks[index] = updatedTask;
    });

    await saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: tasks[index],
                        onToggle: () {
                          toggleTask(index);
                        },
                        onDelete: () {
                          deleteTask(index);
                        },
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTaskScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}