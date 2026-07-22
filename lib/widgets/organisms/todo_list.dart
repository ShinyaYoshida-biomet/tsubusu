import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/design_constants.dart';
import '../../models/todo.dart';
import '../../providers/theme_provider.dart';
import '../molecules/todo_item.dart';

class TodoList extends StatefulWidget {
  final List<Todo> todos;
  final ValueChanged<String> onToggleTodo;
  final ValueChanged<String> onDeleteTodo;
  final void Function(String?, int, int)? onReorderSiblings;
  final void Function(String, String) onAddSubtask;
  final void Function(String, String) onEditTodo;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggleTodo,
    required this.onDeleteTodo,
    required this.onAddSubtask,
    required this.onEditTodo,
    this.onReorderSiblings,
  });

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _collapsedIds = <String>{};
  String? _addingForId;
  double _completedSectionHeight = 200.0;
  final double _minCompletedHeight = 80.0;
  final double _maxCompletedHeight = 400.0;

  List<Todo> _childrenOf(String parentId) =>
      widget.todos.where((todo) => todo.parentId == parentId).toList();

  void _toggleExpanded(String id) {
    setState(() {
      if (!_collapsedIds.add(id)) _collapsedIds.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final roots = widget.todos.where((todo) => todo.parentId == null).toList();
    final openRoots = roots.where((todo) => !todo.isCompleted).toList();
    final completedRoots = roots.where((todo) => todo.isCompleted).toList();
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom;
    final maxCompletedHeight = (availableHeight * 0.45).clamp(
      _minCompletedHeight,
      _maxCompletedHeight,
    );

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Uncompleted (${openRoots.length})',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(8),
                    buildDefaultDragHandles: false,
                    itemCount: openRoots.length,
                    onReorder:
                        (oldIndex, newIndex) => widget.onReorderSiblings?.call(
                          null,
                          oldIndex,
                          newIndex,
                        ),
                    itemBuilder:
                        (context, index) =>
                            _buildGroup(context, openRoots[index], index),
                  ),
                ),
              ],
            ),
          ),
          if (completedRoots.isNotEmpty)
            Column(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    onPanUpdate:
                        (details) => setState(() {
                          _completedSectionHeight = (_completedSectionHeight -
                                  details.delta.dy)
                              .clamp(_minCompletedHeight, maxCompletedHeight);
                        }),
                    child: Container(
                      height: 8,
                      color: themeProvider.borderColor,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: themeProvider.completedTextColor.withValues(
                              alpha: DesignConstants.opacityMedium,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: _completedSectionHeight.clamp(
                    _minCompletedHeight,
                    maxCompletedHeight,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.completedSectionColor,
                    border: Border(
                      top: BorderSide(color: themeProvider.borderColor),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Completed (${completedRoots.length})',
                          style: TextStyle(
                            color: themeProvider.completedTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: completedRoots.length,
                          itemBuilder:
                              (context, index) => _buildGroup(
                                context,
                                completedRoots[index],
                                null,
                                completed: true,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    Todo parent,
    int? rootReorderIndex, {
    bool completed = false,
  }) {
    final children = _childrenOf(parent.id);
    final isExpanded = !_collapsedIds.contains(parent.id);
    final completedChildren = children.where((todo) => todo.isCompleted).length;
    return Container(
      key: ValueKey(parent.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TodoItem(
            todo: parent,
            onToggle: () => widget.onToggleTodo(parent.id),
            onDelete: () => widget.onDeleteTodo(parent.id),
            onAddSubtask: () => setState(() => _addingForId = parent.id),
            onEdit: (text) => widget.onEditTodo(parent.id, text),
            hasChildren: children.isNotEmpty,
            isExpanded: isExpanded,
            onToggleExpanded: () => _toggleExpanded(parent.id),
            reorderIndex: completed ? null : rootReorderIndex,
            isCompleted: completed,
          ),
          if (children.isNotEmpty && isExpanded)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: children.length,
              onReorder:
                  (oldIndex, newIndex) => widget.onReorderSiblings?.call(
                    parent.id,
                    oldIndex,
                    newIndex,
                  ),
              itemBuilder: (context, index) {
                final child = children[index];
                return Padding(
                  key: ValueKey(child.id),
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: TodoItem(
                    todo: child,
                    isSubtask: true,
                    onToggle: () => widget.onToggleTodo(child.id),
                    onDelete: () => widget.onDeleteTodo(child.id),
                    onEdit: (text) => widget.onEditTodo(child.id, text),
                    reorderIndex: completed ? null : index,
                    isCompleted: completed,
                  ),
                );
              },
            ),
          if (_addingForId == parent.id)
            Padding(
              padding: const EdgeInsets.only(left: 56, right: 8, bottom: 8),
              child: _SubtaskInput(
                onSubmit: (text) {
                  setState(() => _addingForId = null);
                  if (text.trim().isNotEmpty) {
                    widget.onAddSubtask(parent.id, text);
                  }
                },
                onCancel: () => setState(() => _addingForId = null),
              ),
            ),
          if (children.isNotEmpty && !completed)
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 6),
              child: Text(
                '$completedChildren/${children.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubtaskInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;

  const _SubtaskInput({required this.onSubmit, required this.onCancel});

  @override
  State<_SubtaskInput> createState() => _SubtaskInputState();
}

class _SubtaskInputState extends State<_SubtaskInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    autofocus: true,
    decoration: const InputDecoration(hintText: 'サブタスクを追加…', isDense: true),
    onSubmitted: widget.onSubmit,
    onTapOutside: (_) => widget.onCancel(),
  );
}
