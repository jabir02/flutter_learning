import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import 'task_storage_service.dart';

class TaskRepository {
  final TaskStorageService storageService;

  const TaskRepository({
    required this.storageService,
  });

  Future<List<Task>> loadTasks() {
    return storageService.loadTasks();
  }

  Future<void> saveTasks(List<Task> tasks) {
    return storageService.saveTasks(tasks);
  }
}

final taskStorageServiceProvider = Provider<TaskStorageService>((ref) {
  return TaskStorageService();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    storageService: ref.watch(taskStorageServiceProvider),
  );
});