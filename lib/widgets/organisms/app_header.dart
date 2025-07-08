import 'package:flutter/material.dart';
import '../atoms/custom_button.dart';
import '../molecules/add_todo_form.dart';

class AppHeader extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAddTodo;
  final VoidCallback onShowSettings;
  final String windowTitle;
  final ValueChanged<String> onTitleChanged;

  const AppHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onAddTodo,
    required this.onShowSettings,
    required this.windowTitle,
    required this.onTitleChanged,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.windowTitle);
    _titleController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(AppHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.windowTitle != widget.windowTitle && _titleController.text != widget.windowTitle) {
      _titleController.removeListener(_onTextChanged);
      _titleController.text = widget.windowTitle;
      _titleController.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    widget.onTitleChanged(_titleController.text);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with settings button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _titleController,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      isDense: true,
                      hintText: 'Enter title...',
                      hintStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    maxLines: 1,
                    cursorColor: Colors.white,
                    cursorWidth: 2.0,
                    cursorHeight: 24.0,
                    enableInteractiveSelection: true,
                    mouseCursor: SystemMouseCursors.text,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Settings button
              IconButtonAtom(
                icon: Icons.settings,
                onPressed: widget.onShowSettings,
                iconColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Add todo form
          AddTodoForm(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onAdd: widget.onAddTodo,
          ),
        ],
      ),
    );
  }
}