import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../atoms/custom_button.dart';
import '../atoms/custom_text.dart';

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
      child: InkWell(
        onTap: onToggle, // Make entire card clickable for completion
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Drag handle (hamburger menu) - only for open tasks
              if (!todo.isCompleted && reorderIndex != null)
                ReorderableDragStartListener(
                  index: reorderIndex!,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomText(
                  todo.text,
                  style: TextStyle(
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: todo.isCompleted ? Colors.grey : null,
                  ),
                ),
              ),
              IconButtonAtom(
                icon: Icons.delete_outline,
                onPressed: onDelete,
                iconColor: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}