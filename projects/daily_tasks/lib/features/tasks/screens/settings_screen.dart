import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_settings_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> confirmClearAll(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool shouldClear = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Clear all tasks?'),
              content: const Text(
                'This will permanently remove every task from TaskNest.',
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
                  child: const Text('Clear all'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldClear) {
      return;
    }

    await ref.read(tasksControllerProvider.notifier).clearAllTasks();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All tasks cleared'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsControllerProvider);
    final tasksState = ref.watch(tasksControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              value: appSettings.isDarkMode,
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between light and dark theme'),
              onChanged: (value) {
                ref
                    .read(appSettingsControllerProvider.notifier)
                    .setDarkMode(value);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Clear all tasks'),
              subtitle: Text('${tasksState.totalCount} tasks currently saved'),
              onTap: tasksState.totalCount == 0
                  ? null
                  : () {
                      confirmClearAll(context, ref);
                    },
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About TaskNest'),
              subtitle: Text(
                'A Flutter productivity showcase app with routing, state management, local storage, filtering, sorting, and tests.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}