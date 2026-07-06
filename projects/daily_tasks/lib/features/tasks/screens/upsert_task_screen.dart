import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/tasks_controller.dart';
import '../models/task.dart';

class UpsertTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const UpsertTaskScreen({
    super.key,
    this.taskId,
  });

  @override
  ConsumerState<UpsertTaskScreen> createState() => _UpsertTaskScreenState();
}

class _UpsertTaskScreenState extends ConsumerState<UpsertTaskScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  TaskPriority selectedPriority = TaskPriority.medium;
  TaskCategory selectedCategory = TaskCategory.personal;
  DateTime? selectedDueDate;

  bool didInitialize = false;

  bool get isEditMode {
    return widget.taskId != null;
  }

  String formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  void initializeForm(Task? task) {
    if (didInitialize) {
      return;
    }

    titleController.text = task?.title ?? '';
    descriptionController.text = task?.description ?? '';
    selectedPriority = task?.priority ?? TaskPriority.medium;
    selectedCategory = task?.category ?? TaskCategory.personal;
    selectedDueDate = task?.dueDate;

    didInitialize = true;
  }

  Future<void> pickDueDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDueDate = pickedDate;
    });
  }

  Future<void> saveTask(Task? editingTask) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final TasksController controller =
        ref.read(tasksControllerProvider.notifier);

    final String title = titleController.text.trim();
    final String description = descriptionController.text.trim();

    if (isEditMode && editingTask != null) {
      await controller.updateTask(
        editingTask.copyWith(
          title: title,
          description: description,
          priority: selectedPriority,
          category: selectedCategory,
          dueDate: selectedDueDate,
          clearDueDate: selectedDueDate == null,
        ),
      );
    } else {
      await controller.addTask(
        title: title,
        description: description,
        priority: selectedPriority,
        category: selectedCategory,
        dueDate: selectedDueDate,
      );
    }

    if (!mounted) {
      return;
    }

    context.pop();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TasksState state = ref.watch(tasksControllerProvider);
    final Task? editingTask =
        widget.taskId == null ? null : state.taskById(widget.taskId!);

    if (isEditMode && state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isEditMode && editingTask == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task not found'),
        ),
        body: const Center(
          child: Text('This task no longer exists.'),
        ),
      );
    }

    initializeForm(editingTask);

    final String title = isEditMode ? 'Edit Task' : 'Add Task';
    final String buttonText = isEditMode ? 'Update Task' : 'Save Task';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                key: const ValueKey('task-title-field'),
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required';
                  }

                  if (value.trim().length < 3) {
                    return 'Task title must be at least 3 characters';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('task-description-field'),
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskPriority>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(priority.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedPriority = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: TaskCategory.values.map((category) {
                  return DropdownMenuItem<TaskCategory>(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                    selectedDueDate == null
                        ? 'No due date'
                        : 'Due ${formatDate(selectedDueDate!)}',
                  ),
                  subtitle: const Text('Tap to select a due date'),
                  onTap: pickDueDate,
                  trailing: selectedDueDate == null
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDueDate = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const ValueKey('save-task-button'),
                onPressed: () {
                  saveTask(editingTask);
                },
                icon: const Icon(Icons.check),
                label: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}