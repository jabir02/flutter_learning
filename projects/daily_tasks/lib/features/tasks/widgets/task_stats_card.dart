import 'package:flutter/material.dart';

class TaskStatsCard extends StatelessWidget {
  final int total;
  final int active;
  final int completed;

  const TaskStatsCard({
    super.key,
    required this.total,
    required this.active,
    required this.completed,
  });

  double get progress {
    if (total == 0) {
      return 0;
    }

    return completed / total;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total',
                    value: total.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Active',
                    value: active.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Done',
                    value: completed.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}