import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/tasks_controller.dart';
import '../models/task.dart';

class TaskDetailsScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  String formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  Future<void> confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete task?'),
              content: Text('Delete "${task.title}" permanently?'),
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

    await ref.read(tasksControllerProvider.notifier).deleteTask(task.id);

    if (!context.mounted) {
      return;
    }

    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TasksState state = ref.watch(tasksControllerProvider);
    final Task? task = state.taskById(taskId);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (task == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task not found'),
        ),
        body: const Center(
          child: Text('This task no longer exists.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            tooltip: 'Edit task',
            onPressed: () {
              context.pushNamed(
                'editTask',
                pathParameters: {
                  'id': task.id,
                },
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: () {
              confirmDelete(context, ref, task);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            task.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            task.description.isEmpty
                ? 'No description added.'
                : task.description,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(task.isCompleted ? 'Completed' : 'Active'),
              ),
              Chip(
                label: Text(task.priority.label),
              ),
              Chip(
                label: Text(task.category.label),
              ),
              if (task.dueDate != null)
                Chip(
                  label: Text('Due ${formatDate(task.dueDate!)}'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              value: task.isCompleted,
              title: const Text('Completed'),
              subtitle: const Text('Toggle task completion status'),
              onChanged: (_) {
                ref.read(tasksControllerProvider.notifier).toggleTask(task.id);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Created'),
                  subtitle: Text(formatDate(task.createdAt)),
                ),
                ListTile(
                  leading: const Icon(Icons.update_outlined),
                  title: const Text('Last updated'),
                  subtitle: Text(formatDate(task.updatedAt)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}