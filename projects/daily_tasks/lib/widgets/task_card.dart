import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.title,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}