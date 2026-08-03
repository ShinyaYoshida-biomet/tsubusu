import 'dart:async';

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
  final Future<bool> Function(String, String)? onNestTodo;
  final Future<void> Function()? onUndoNesting;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggleTodo,
    required this.onDeleteTodo,
    required this.onAddSubtask,
    required this.onEditTodo,
    this.onReorderSiblings,
    this.onNestTodo,
    this.onUndoNesting,
  });

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _collapsedIds = <String>{};
  Timer? _pendingExpansionTimer;
  String? _pendingExpansionId;
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

  void _scheduleExpansion(Todo target) {
    if (_childrenOf(target.id).isNotEmpty &&
        _collapsedIds.contains(target.id)) {
      if (_pendingExpansionId == target.id) return;
      _pendingExpansionTimer?.cancel();
      _pendingExpansionId = target.id;
      _pendingExpansionTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted || _pendingExpansionId != target.id) return;
        setState(() => _collapsedIds.remove(target.id));
        _pendingExpansionId = null;
      });
    }
  }

  void _cancelExpansion() {
    _pendingExpansionTimer?.cancel();
    _pendingExpansionTimer = null;
    _pendingExpansionId = null;
  }

  @override
  void dispose() {
    _cancelExpansion();
    super.dispose();
  }

  bool _canNest(String sourceId, String targetId) {
    if (widget.onNestTodo == null || sourceId == targetId) return false;

    final targetMatches = widget.todos.where((todo) => todo.id == targetId);
    if (targetMatches.isEmpty) return false;
    var current = targetMatches.first;
    final visited = <String>{};
    while (current.parentId != null) {
      if (!visited.add(current.id)) return false;
      if (current.parentId == sourceId) return false;
      final parent = widget.todos.where((todo) => todo.id == current.parentId);
      if (parent.isEmpty) return true;
      current = parent.first;
    }
    return true;
  }

  Future<void> _nestInto(Todo source, Todo target) async {
    final didNest = await widget.onNestTodo?.call(source.id, target.id);
    if (!mounted || didNest != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('サブタスクとして「${target.text}」に移動しました'),
          action:
              widget.onUndoNesting == null
                  ? null
                  : SnackBarAction(
                    label: '元に戻す',
                    onPressed: () => widget.onUndoNesting!.call(),
                  ),
        ),
      );
  }

  Future<void> _chooseNestTarget(BuildContext context, Todo source) async {
    final candidates =
        widget.todos.where((todo) => _canNest(source.id, todo.id)).toList();
    if (candidates.isEmpty) return;

    final target = await showModalBottomSheet<Todo>(
      context: context,
      builder:
          (context) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const ListTile(title: Text('サブタスクにする親タスクを選択')),
                for (final candidate in candidates)
                  ListTile(
                    leading: const Icon(Icons.account_tree_outlined),
                    title: Text(candidate.text),
                    onTap: () => Navigator.pop(context, candidate),
                  ),
              ],
            ),
          ),
    );
    if (!mounted || target == null) return;
    await _nestInto(source, target);
  }

  Widget _nestTarget(
    BuildContext context,
    Todo target,
    Widget child, {
    Key? key,
  }) {
    return DragTarget<String>(
      key: key,
      onWillAcceptWithDetails: (details) {
        final canNest = _canNest(details.data, target.id);
        if (canNest) _scheduleExpansion(target);
        return canNest;
      },
      onLeave: (_) => _cancelExpansion(),
      onAcceptWithDetails: (details) async {
        _cancelExpansion();
        final sources = widget.todos.where((todo) => todo.id == details.data);
        if (sources.isEmpty) return;
        await _nestInto(sources.first, target);
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        final themeProvider = Provider.of<ThemeProvider>(context);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            border:
                isDropTarget
                    ? Border.all(color: themeProvider.primaryColor, width: 2)
                    : null,
            borderRadius: BorderRadius.circular(
              DesignConstants.borderRadiusStandard,
            ),
          ),
          child: child,
        );
      },
    );
  }

  bool _canReorderAt(String? parentId, String sourceId) {
    final source =
        widget.todos.where((todo) => todo.id == sourceId).firstOrNull;
    return source != null && source.parentId == parentId;
  }

  Future<void> _reorderAt(
    String? parentId,
    int dropIndex,
    String sourceId,
  ) async {
    final siblings =
        widget.todos.where((todo) => todo.parentId == parentId).toList();
    final oldIndex = siblings.indexWhere((todo) => todo.id == sourceId);
    if (oldIndex == -1 || oldIndex == dropIndex) return;

    final newIndex =
        dropIndex == siblings.length
            ? dropIndex
            : oldIndex < dropIndex
            ? dropIndex + 1
            : dropIndex;
    widget.onReorderSiblings?.call(parentId, oldIndex, newIndex);
  }

  Widget _reorderDropZone(String? parentId, int dropIndex) {
    return DragTarget<String>(
      key: ValueKey('drop-zone-$parentId-$dropIndex'),
      onWillAcceptWithDetails:
          (details) => _canReorderAt(parentId, details.data),
      onAcceptWithDetails:
          (details) => _reorderAt(parentId, dropIndex, details.data),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        final themeProvider = Provider.of<ThemeProvider>(context);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: isDropTarget ? 24 : 8,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                isDropTarget
                    ? themeProvider.primaryColor.withValues(alpha: 0.35)
                    : Colors.transparent,
          ),
          child:
              isDropTarget
                  ? Center(
                    child: Container(
                      height: 2,
                      color: themeProvider.primaryColor,
                    ),
                  )
                  : null,
        );
      },
    );
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: openRoots.length * 2 + 1,
                    itemBuilder:
                        (context, index) =>
                            index.isEven
                                ? _reorderDropZone(null, index ~/ 2)
                                : _buildGroup(
                                  context,
                                  openRoots[index ~/ 2],
                                  index ~/ 2,
                                ),
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
          _nestTarget(
            context,
            parent,
            TodoItem(
              todo: parent,
              onToggle: () => widget.onToggleTodo(parent.id),
              onDelete: () => widget.onDeleteTodo(parent.id),
              onAddSubtask: () => setState(() => _addingForId = parent.id),
              onMove:
                  !completed ? () => _chooseNestTarget(context, parent) : null,
              onEdit: (text) => widget.onEditTodo(parent.id, text),
              hasChildren: children.isNotEmpty,
              isExpanded: isExpanded,
              onToggleExpanded: () => _toggleExpanded(parent.id),
              reorderIndex: completed ? null : rootReorderIndex,
              isCompleted: completed,
            ),
          ),
          if (children.isNotEmpty && isExpanded)
            Column(
              children: [
                for (var index = 0; index <= children.length; index++) ...[
                  _reorderDropZone(parent.id, index),
                  if (index < children.length)
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: _nestTarget(
                        context,
                        children[index],
                        TodoItem(
                          todo: children[index],
                          isSubtask: true,
                          onToggle:
                              () => widget.onToggleTodo(children[index].id),
                          onDelete:
                              () => widget.onDeleteTodo(children[index].id),
                          onMove:
                              !completed
                                  ? () => _chooseNestTarget(
                                    context,
                                    children[index],
                                  )
                                  : null,
                          onEdit:
                              (text) =>
                                  widget.onEditTodo(children[index].id, text),
                          reorderIndex: completed ? null : index,
                          isCompleted: completed,
                        ),
                      ),
                    ),
                ],
              ],
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
