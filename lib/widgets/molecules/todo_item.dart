import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/design_constants.dart';
import '../../models/todo.dart';
import '../../providers/theme_provider.dart';
import '../atoms/animated_checkbox.dart';
import '../atoms/custom_text.dart';
import '../atoms/icon_button_atom.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onAddSubtask;
  final VoidCallback? onMove;
  final ValueChanged<String>? onEdit;
  final VoidCallback? onToggleExpanded;
  final bool hasChildren;
  final bool isExpanded;
  final int? reorderIndex;
  final bool isCompleted;
  final bool isSubtask;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.onAddSubtask,
    this.onMove,
    this.onEdit,
    this.onToggleExpanded,
    this.hasChildren = false,
    this.isExpanded = true,
    this.reorderIndex,
    this.isCompleted = false,
    this.isSubtask = false,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  final _editController = TextEditingController();
  final _editFocusNode = FocusNode();
  bool _isHovered = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    if (widget.onEdit == null) return;
    setState(() {
      _isEditing = true;
      _editController.text = widget.todo.text;
      _editController.selection = TextSelection.collapsed(
        offset: _editController.text.length,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editFocusNode.requestFocus();
    });
  }

  void _finishEditing({bool cancel = false}) {
    if (!_isEditing) return;
    final text = _editController.text.trim();
    setState(() => _isEditing = false);
    if (!cancel && text.isNotEmpty && text != widget.todo.text) {
      widget.onEdit?.call(text);
    }
  }

  void _showActions(BuildContext context, [Offset? globalPosition]) {
    final isApplePlatform = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };

    if (isApplePlatform) {
      showCupertinoModalPopup<String>(
        context: context,
        builder:
            (context) => CupertinoActionSheet(
              actions: [
                if (widget.hasChildren && widget.onToggleExpanded != null)
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context, 'collapse'),
                    child: Text(widget.isExpanded ? '折りたたむ' : '展開する'),
                  ),
                if (widget.onAddSubtask != null)
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context, 'add'),
                    child: const Text('サブタスクを追加'),
                  ),
                if (widget.onMove != null)
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context, 'move'),
                    child: const Text('別のタスクのサブタスクにする'),
                  ),
                if (widget.onEdit != null)
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context, 'edit'),
                    child: const Text('名前を変更'),
                  ),
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context, 'delete'),
                  child: const Text('削除'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
            ),
      ).then(_handleAction);
      return;
    }

    final box = context.findRenderObject() as RenderBox;
    final position = globalPosition ?? box.localToGlobal(Offset.zero);
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + box.size.height,
        position.dx + 1,
        position.dy,
      ),
      items: [
        if (widget.hasChildren && widget.onToggleExpanded != null)
          PopupMenuItem(
            value: 'collapse',
            child: Text(widget.isExpanded ? '折りたたむ' : '展開する'),
          ),
        if (widget.onAddSubtask != null)
          const PopupMenuItem(value: 'add', child: Text('サブタスクを追加')),
        if (widget.onMove != null)
          const PopupMenuItem(value: 'move', child: Text('別のタスクのサブタスクにする')),
        if (widget.onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('名前を変更')),
        const PopupMenuItem(value: 'delete', child: Text('削除')),
      ],
    ).then(_handleAction);
  }

  void _handleAction(String? value) {
    if (!mounted) return;
    switch (value) {
      case 'collapse':
        widget.onToggleExpanded?.call();
      case 'add':
        widget.onAddSubtask?.call();
      case 'move':
        widget.onMove?.call();
      case 'edit':
        _startEditing();
      case 'delete':
        widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textStyle = TextStyle(
      decoration: widget.todo.isCompleted ? TextDecoration.lineThrough : null,
      color:
          widget.todo.isCompleted
              ? themeProvider.completedTextColor
              : themeProvider.textColor,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: EdgeInsets.only(bottom: DesignConstants.spacingSmall),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(
            DesignConstants.borderRadiusStandard,
          ),
          boxShadow: [
            BoxShadow(
              color: themeProvider.shadowColor,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.only(
            left:
                widget.isSubtask
                    ? DesignConstants.spacingMedium * 2
                    : DesignConstants.spacingSmall,
            right: DesignConstants.spacingSmall,
          ),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedCheckbox(
                value: widget.todo.isCompleted,
                onChanged: (_) => widget.onToggle(),
                activeColor: themeProvider.primaryColor,
                isStatic: widget.isCompleted,
              ),
            ],
          ),
          title:
              _isEditing
                  ? TextField(
                    controller: _editController,
                    focusNode: _editFocusNode,
                    autofocus: true,
                    onSubmitted: (_) => _finishEditing(),
                    onEditingComplete: _finishEditing,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  )
                  : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onSecondaryTapUp:
                        (details) =>
                            _showActions(context, details.globalPosition),
                    onLongPress: () => _showActions(context),
                    onDoubleTap: _startEditing,
                    child: CustomText(widget.todo.text, style: textStyle),
                  ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isHovered && !_isEditing)
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showActions(context),
                  tooltip: 'その他の操作',
                ),
              IconButtonAtom(
                icon: Icons.delete_outline,
                onPressed: widget.onDelete,
                iconColor: themeProvider.completedTextColor,
                size: DesignConstants.iconSizeStandard,
              ),
              if (!widget.todo.isCompleted && widget.reorderIndex != null) ...[
                SizedBox(width: DesignConstants.spacingSmall),
                LongPressDraggable<String>(
                  data: widget.todo.id,
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(
                      DesignConstants.borderRadiusStandard,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.drag_handle),
                        title: Text(widget.todo.text),
                      ),
                    ),
                  ),
                  child: const Tooltip(
                    message: 'Drag to reorder or make a subtask',
                    child: Icon(Icons.drag_handle),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
