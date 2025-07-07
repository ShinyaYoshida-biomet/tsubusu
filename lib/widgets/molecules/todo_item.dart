import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../atoms/custom_button.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: AnimatedCheckbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        title: CustomText(
          todo.text,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButtonAtom(
              icon: Icons.delete_outline,
              onPressed: onDelete,
              iconColor: Colors.grey,
              size: 20,
            ),
            // Hamburger menu for drag and drop (only for open tasks)
            if (!todo.isCompleted && reorderIndex != null) ...[
              const SizedBox(width: 8),
              ReorderableDragStartListener(
                index: reorderIndex!,
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.grey[400],
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