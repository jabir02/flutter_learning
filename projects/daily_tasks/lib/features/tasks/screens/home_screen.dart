import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/tasks_controller.dart';
import '../models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import '../widgets/task_stats_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _confirmClearCompleted(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool shouldClear = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Clear completed tasks?'),
              content: const Text(
                'This will remove all completed tasks from your list.',
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

    await ref.read(tasksControllerProvider.notifier).clearCompletedTasks();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completed tasks cleared'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete task?'),
              content: Text('Delete "${task.title}" from your list?'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TasksState state = ref.watch(tasksControllerProvider);
    final TasksController controller =
        ref.read(tasksControllerProvider.notifier);

    final List<Task> visibleTasks = state.visibleTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskNest'),
        actions: [
          if (state.completedCount > 0)
            IconButton(
              tooltip: 'Clear completed',
              onPressed: () {
                _confirmClearCompleted(context, ref);
              },
              icon: const Icon(Icons.cleaning_services_outlined),
            ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              context.pushNamed('settings');
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    TaskStatsCard(
                      total: state.totalCount,
                      active: state.activeCount,
                      completed: state.completedCount,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const ValueKey('task-search-field'),
                      onChanged: controller.setSearchQuery,
                      decoration: const InputDecoration(
                        labelText: 'Search tasks',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<TaskFilter>(
                            segments: TaskFilter.values.map((filter) {
                              return ButtonSegment<TaskFilter>(
                                value: filter,
                                label: Text(filter.label),
                              );
                            }).toList(),
                            selected: {
                              state.filter,
                            },
                            onSelectionChanged: (selected) {
                              controller.setFilter(selected.first);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<TaskSort>(
                          tooltip: 'Sort tasks',
                          icon: const Icon(Icons.sort),
                          onSelected: controller.setSort,
                          itemBuilder: (context) {
                            return TaskSort.values.map((sort) {
                              return PopupMenuItem<TaskSort>(
                                value: sort,
                                child: Text(sort.label),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: visibleTasks.isEmpty
                          ? EmptyState(
                              title: 'No tasks yet',
                              message: state.searchQuery.trim().isNotEmpty
                                  ? 'No task matches your search.'
                                  : 'Tap the plus button to create your first task.',
                            )
                          : ListView.separated(
                              itemCount: visibleTasks.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 8);
                              },
                              itemBuilder: (context, index) {
                                final Task task = visibleTasks[index];

                                return TaskCard(
                                  task: task,
                                  onTap: () {
                                    context.pushNamed(
                                      'taskDetails',
                                      pathParameters: {
                                        'id': task.id,
                                      },
                                    );
                                  },
                                  onToggle: () {
                                    controller.toggleTask(task.id);
                                  },
                                  onEdit: () {
                                    context.pushNamed(
                                      'editTask',
                                      pathParameters: {
                                        'id': task.id,
                                      },
                                    );
                                  },
                                  onDelete: () {
                                    _confirmDelete(context, ref, task);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('addTask');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}