import 'package:flutter/material.dart';

import '../../models/todo.dart';
import '../../models/todo_list_history.dart';
import '../../models/todo_list_id.dart';
import '../../services/todo_list_catalog_service.dart';

class TaskHistoryDialog extends StatefulWidget {
  final TodoListCatalogService catalog;

  const TaskHistoryDialog({super.key, required this.catalog});

  @override
  State<TaskHistoryDialog> createState() => _TaskHistoryDialogState();
}

class _TaskHistoryDialogState extends State<TaskHistoryDialog> {
  bool _includeEmpty = false;

  Future<void> _previewHistory(TodoListHistory history) async {
    final shouldRestore = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => _TaskHistoryPreviewDialog(history: history),
    );
    if (shouldRestore != true || !mounted) return;

    final restored = await widget.catalog.restoreHistory(history);
    if (mounted) Navigator.pop<TodoListId>(context, restored.id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Task history'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
        child: SizedBox(
          width: double.infinity,
          height: 420,
          child: FutureBuilder<List<TodoListHistory>>(
            future: widget.catalog.loadTaskHistory(includeEmpty: _includeEmpty),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final histories = snapshot.data!;
              if (histories.isEmpty) {
                return const Center(child: Text('No task history found.'));
              }
              return ListView.separated(
                itemCount: histories.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final history = histories[index];
                  return ListTile(
                    title: Text(history.recencyLabel),
                    subtitle: Text(
                      '${history.taskCount} tasks · ${history.formatLabel}',
                    ),
                    trailing: TextButton(
                      onPressed: () => _previewHistory(history),
                      child: const Text('View'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _includeEmpty = !_includeEmpty),
          child: Text(
            _includeEmpty ? 'Hide empty histories' : 'Show empty histories',
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _TaskHistoryPreviewDialog extends StatelessWidget {
  final TodoListHistory history;

  const _TaskHistoryPreviewDialog({required this.history});

  int _depthOf(Todo todo) {
    var depth = 0;
    var parentId = todo.parentId;
    final visited = <String>{};
    while (parentId != null && visited.add(parentId)) {
      depth++;
      final parent = history.todos.where((item) => item.id == parentId);
      if (parent.isEmpty) break;
      parentId = parent.first.parentId;
    }
    return depth;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text('${history.recencyLabel} · ${history.taskCount} tasks'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 360),
        child: SizedBox(
          width: double.infinity,
          height: 360,
          child: ListView.builder(
            itemCount: history.todos.length,
            itemBuilder: (context, index) {
              final todo = history.todos[index];
              return ListTile(
                contentPadding: EdgeInsets.only(
                  left: 16.0 + _depthOf(todo) * 20,
                ),
                leading: Icon(
                  todo.isCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                title: Text(todo.text),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Restore as new list'),
        ),
      ],
    );
  }
}
