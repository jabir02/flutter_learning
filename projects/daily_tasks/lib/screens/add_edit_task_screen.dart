import 'package:flutter/material.dart';

import '../models/task.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({
    super.key,
    this.task,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TextEditingController titleController = TextEditingController();

  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.task?.title ?? '';
  }

  void saveTask() {
    final String title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title cannot be empty'),
        ),
      );

      return;
    }

    final Task resultTask = isEditMode
        ? widget.task!.copyWith(title: title)
        : Task(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            isCompleted: false,
            createdAt: DateTime.now(),
          );

    Navigator.pop(context, resultTask);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String screenTitle = isEditMode ? 'Edit Task' : 'Add Task';
    final String buttonText = isEditMode ? 'Update Task' : 'Save Task';

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                saveTask();
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTask,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}