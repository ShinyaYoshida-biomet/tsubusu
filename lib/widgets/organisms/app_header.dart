import 'package:flutter/material.dart';
import '../atoms/custom_text.dart';
import '../atoms/custom_button.dart';
import '../molecules/add_todo_form.dart';

class AppHeader extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAddTodo;
  final VoidCallback onShowSettings;

  const AppHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onAddTodo,
    required this.onShowSettings,
  });

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
          const TitleText(
            'Tsubusu',
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AddTodoForm(
                controller: controller,
                focusNode: focusNode,
                onAdd: onAddTodo,
              ),
              const SizedBox(width: 10),
              // Settings button
              IconButtonAtom(
                icon: Icons.settings,
                onPressed: onShowSettings,
                iconColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}