import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

enum TaskFilter {
  all,
  active,
  completed,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskStorageService taskStorageService = TaskStorageService();

  List<Task> tasks = [];
  TaskFilter selectedFilter = TaskFilter.all;
  bool isLoading = true;

  int get totalCount => tasks.length;

  int get completedCount {
    return tasks.where((task) => task.isCompleted).length;
  }

  int get activeCount {
    return tasks.where((task) => !task.isCompleted).length;
  }

  List<Task> get filteredTasks {
    switch (selectedFilter) {
      case TaskFilter.active:
        return tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.all:
        return tasks;
    }
  }

  @override
  void initState() {
    super.initState();

    loadTasks();
  }

  Future<void> loadTasks() async {
    final List<Task> loadedTasks = await taskStorageService.loadTasks();

    if (!mounted) {
      return;
    }

    setState(() {
      tasks = loadedTasks;
      isLoading = false;
    });
  }

  Future<void> saveTasks() async {
    await taskStorageService.saveTasks(tasks);
  }

  Future<void> openAddTaskScreen() async {
    final Task? newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );

    if (newTask == null) {
      return;
    }

    setState(() {
      tasks.add(newTask);
    });

    await saveTasks();
  }

  Future<void> openEditTaskScreen(Task task) async {
    final Task? updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    );

    if (updatedTask == null) {
      return;
    }

    final int index = tasks.indexWhere((currentTask) {
      return currentTask.id == updatedTask.id;
    });

    if (index == -1) {
      return;
    }

    setState(() {
      tasks[index] = updatedTask;
    });

    await saveTasks();
  }

  Future<void> toggleTask(Task task) async {
    final int index = tasks.indexWhere((currentTask) {
      return currentTask.id == task.id;
    });

    if (index == -1) {
      return;
    }

    setState(() {
      tasks[index] = task.copyWith(
        isCompleted: !task.isCompleted,
      );
    });

    await saveTasks();
  }

  Future<void> deleteTask(Task task) async {
    final bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete task?'),
              content: Text('Are you sure you want to delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    setState(() {
      tasks.removeWhere((currentTask) {
        return currentTask.id == task.id;
      });
    });

    await saveTasks();
  }

  Future<void> clearCompletedTasks() async {
    if (completedCount == 0) {
      return;
    }

    final bool shouldClear = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Clear completed tasks?'),
              content: const Text(
                'This will remove all completed tasks from the list.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldClear) {
      return;
    }

    setState(() {
      tasks.removeWhere((task) {
        return task.isCompleted;
      });
    });

    await saveTasks();
  }

  Widget buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: buildStatItem(
                label: 'Total',
                value: totalCount.toString(),
              ),
            ),
            Expanded(
              child: buildStatItem(
                label: 'Active',
                value: activeCount.toString(),
              ),
            ),
            Expanded(
              child: buildStatItem(
                label: 'Done',
                value: completedCount.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatItem({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget buildFilterBar() {
    return SegmentedButton<TaskFilter>(
      segments: const [
        ButtonSegment<TaskFilter>(
          value: TaskFilter.all,
          label: Text('All'),
        ),
        ButtonSegment<TaskFilter>(
          value: TaskFilter.active,
          label: Text('Active'),
        ),
        ButtonSegment<TaskFilter>(
          value: TaskFilter.completed,
          label: Text('Done'),
        ),
      ],
      selected: {selectedFilter},
      onSelectionChanged: (Set<TaskFilter> selected) {
        setState(() {
          selectedFilter = selected.first;
        });
      },
    );
  }

  Widget buildTaskList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredTasks.isEmpty) {
      return EmptyState(
        title: 'No tasks found',
        message: selectedFilter == TaskFilter.all
            ? 'Tap the plus button to add your first task.'
            : 'There are no tasks in this filter.',
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final Task task = filteredTasks[index];

        return TaskCard(
          task: task,
          onToggle: () {
            toggleTask(task);
          },
          onEdit: () {
            openEditTaskScreen(task);
          },
          onDelete: () {
            deleteTask(task);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks'),
        actions: [
          if (completedCount > 0)
            IconButton(
              tooltip: 'Clear completed',
              onPressed: clearCompletedTasks,
              icon: const Icon(Icons.cleaning_services),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildStatsCard(),
            const SizedBox(height: 12),
            buildFilterBar(),
            const SizedBox(height: 12),
            Expanded(
              child: buildTaskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddTaskScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}