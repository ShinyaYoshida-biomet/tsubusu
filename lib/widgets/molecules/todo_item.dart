import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/theme_provider.dart';
import '../atoms/icon_button_atom.dart';
import '../atoms/custom_text.dart';
import '../atoms/animated_checkbox.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final int? reorderIndex; // For drag handle

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.reorderIndex,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: themeProvider.shadowColor,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: AnimatedCheckbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
          activeColor: themeProvider.primaryColor,
        ),
        title: CustomText(
          todo.text,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? themeProvider.completedTextColor : themeProvider.textColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButtonAtom(
              icon: Icons.delete_outline,
              onPressed: onDelete,
              iconColor: themeProvider.completedTextColor,
              size: 20,
            ),
            // Hamburger menu for drag and drop (only for open tasks)
            if (!todo.isCompleted && reorderIndex != null) ...[
              const SizedBox(width: 8),
              ReorderableDragStartListener(
                index: reorderIndex!,
                child: Icon(
                  Icons.drag_handle,
                  color: themeProvider.completedTextColor,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
        onTap: () => onToggle(), // Make entire card clickable
      ),
    );
  }
}
