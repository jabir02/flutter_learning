import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String tasksStorageKey = 'daily_tasks';

  final TextEditingController taskController = TextEditingController();

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

  Future<void> addTask() async {
    final String taskText = taskController.text.trim();

    if (taskText.isEmpty) {
      return;
    }

    final Task newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: taskText,
    );

    setState(() {
      tasks.add(newTask);
      taskController.clear();
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
  void dispose() {
    taskController.dispose();
    super.dispose();
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
            : Column(
                children: [
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) {
                      addTask();
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addTask,
                      child: const Text('Add Task'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: tasks.isEmpty
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
                ],
              ),
      ),
    );
  }
}