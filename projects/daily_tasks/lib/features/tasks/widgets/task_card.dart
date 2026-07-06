import 'package:flutter/material.dart';

import '../models/task.dart';

enum _TaskCardAction {
  edit,
  delete,
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  String formatDate(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String year = dateTime.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                onToggle();
              },
            ),
            title: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(task.priority.label),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(task.category.label),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (task.dueDate != null)
                    Chip(
                      label: Text(
                        task.isOverdue
                            ? 'Overdue ${formatDate(task.dueDate!)}'
                            : 'Due ${formatDate(task.dueDate!)}',
                      ),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: task.isOverdue
                            ? colorScheme.error
                            : colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            trailing: PopupMenuButton<_TaskCardAction>(
              onSelected: (action) {
                switch (action) {
                  case _TaskCardAction.edit:
                    onEdit();
                  case _TaskCardAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: _TaskCardAction.edit,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: _TaskCardAction.delete,
                    child: Text('Delete'),
                  ),
                ];
              },
            ),
          ),
        ),
      ),
    );
  }
}