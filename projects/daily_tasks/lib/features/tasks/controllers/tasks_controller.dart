import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_repository.dart';
import '../models/task.dart';

class TasksState {
  final List<Task> tasks;
  final TaskFilter filter;
  final TaskSort sort;
  final String searchQuery;
  final bool isLoading;

  const TasksState({
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.sort = TaskSort.newest,
    this.searchQuery = '',
    this.isLoading = true,
  });

  int get totalCount {
    return tasks.length;
  }

  int get completedCount {
    return tasks.where((task) {
      return task.isCompleted;
    }).length;
  }

  int get activeCount {
    return tasks.where((task) {
      return !task.isCompleted;
    }).length;
  }

  Task? taskById(String id) {
    for (final Task task in tasks) {
      if (task.id == id) {
        return task;
      }
    }

    return null;
  }

  List<Task> get visibleTasks {
    final String query = searchQuery.trim().toLowerCase();

    final List<Task> result = tasks.where((task) {
      final bool matchesFilter = switch (filter) {
        TaskFilter.all => true,
        TaskFilter.active => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };

      final bool matchesSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.category.label.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();

    result.sort((a, b) {
      switch (sort) {
        case TaskSort.newest:
          return b.createdAt.compareTo(a.createdAt);
        case TaskSort.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case TaskSort.priority:
          return b.priority.rank.compareTo(a.priority.rank);
        case TaskSort.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            return 0;
          }

          if (a.dueDate == null) {
            return 1;
          }

          if (b.dueDate == null) {
            return -1;
          }

          return a.dueDate!.compareTo(b.dueDate!);
      }
    });

    return result;
  }

  TasksState copyWith({
    List<Task>? tasks,
    TaskFilter? filter,
    TaskSort? sort,
    String? searchQuery,
    bool? isLoading,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TasksController extends Notifier<TasksState> {
  @override
  TasksState build() {
    Future.microtask(loadTasks);

    return const TasksState();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true);

    final List<Task> loadedTasks =
        await ref.read(taskRepositoryProvider).loadTasks();

    state = state.copyWith(
      tasks: loadedTasks,
      isLoading: false,
    );
  }

  Future<void> addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskCategory category,
    required DateTime? dueDate,
  }) async {
    final DateTime now = DateTime.now();

    final Task task = Task(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      isCompleted: false,
      priority: priority,
      category: category,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );

    state = state.copyWith(
      tasks: [
        ...state.tasks,
        task,
      ],
    );

    await _saveTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    final List<Task> updatedTasks = state.tasks.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask.copyWith(
          updatedAt: DateTime.now(),
        );
      }

      return task;
    }).toList();

    state = state.copyWith(tasks: updatedTasks);

    await _saveTasks();
  }

  Future<void> toggleTask(String taskId) async {
    final List<Task> updatedTasks = state.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(
          isCompleted: !task.isCompleted,
          updatedAt: DateTime.now(),
        );
      }

      return task;
    }).toList();

    state = state.copyWith(tasks: updatedTasks);

    await _saveTasks();
  }

  Future<void> deleteTask(String taskId) async {
    state = state.copyWith(
      tasks: state.tasks.where((task) {
        return task.id != taskId;
      }).toList(),
    );

    await _saveTasks();
  }

  Future<void> clearCompletedTasks() async {
    state = state.copyWith(
      tasks: state.tasks.where((task) {
        return !task.isCompleted;
      }).toList(),
    );

    await _saveTasks();
  }

  Future<void> clearAllTasks() async {
    state = state.copyWith(tasks: []);

    await _saveTasks();
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSort(TaskSort sort) {
    state = state.copyWith(sort: sort);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> _saveTasks() async {
    await ref.read(taskRepositoryProvider).saveTasks(state.tasks);
  }
}

final tasksControllerProvider =
    NotifierProvider<TasksController, TasksState>(
  TasksController.new,
);