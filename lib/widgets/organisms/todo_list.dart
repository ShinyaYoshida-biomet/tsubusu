import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/theme_provider.dart';
import '../molecules/todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(int) onToggleTodo;
  final Function(int) onDeleteTodo;
  final Function(int, int)? onReorderTodo;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggleTodo,
    required this.onDeleteTodo,
    this.onReorderTodo,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final openTasks = todos.where((todo) => !todo.isCompleted).toList();
    final completedTasks = todos.where((todo) => todo.isCompleted).toList();
    
    return Expanded(
      child: Column(
        children: [
          // Open tasks section with drag and drop
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: openTasks.length,
              buildDefaultDragHandles: false, // Use custom drag handles
              onReorder: (oldIndex, newIndex) {
                if (onReorderTodo != null) {
                  // Convert open task indices to original todo list indices
                  final oldTodo = openTasks[oldIndex];
                  final originalOldIndex = todos.indexWhere((t) => t.id == oldTodo.id);
                  
                  // Adjust newIndex for ReorderableListView behavior
                  if (newIndex > oldIndex) {
                    newIndex--; // When moving down, newIndex is off by 1
                  }
                  
                  // Calculate the new position in the original list
                  int originalNewIndex;
                  if (newIndex >= openTasks.length) {
                    // Moving to the end of open tasks
                    originalNewIndex = todos.lastIndexWhere((t) => !t.isCompleted);
                  } else {
                    final newTodo = openTasks[newIndex];
                    originalNewIndex = todos.indexWhere((t) => t.id == newTodo.id);
                  }
                  
                  onReorderTodo!(originalOldIndex, originalNewIndex);
                }
              },
              itemBuilder: (context, index) {
                final todo = openTasks[index];
                final originalIndex = todos.indexWhere((t) => t.id == todo.id);
                
                return TodoItem(
                  key: ValueKey(todo.id),
                  todo: todo,
                  reorderIndex: index,
                  onToggle: () => onToggleTodo(originalIndex),
                  onDelete: () => onDeleteTodo(originalIndex),
                );
              },
            ),
          ),
          
          // Completed tasks section - at the bottom
          if (completedTasks.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: themeProvider.completedSectionColor,
                border: Border(
                  top: BorderSide(color: themeProvider.borderColor, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Completed (${completedTasks.length})',
                      style: TextStyle(
                        color: themeProvider.completedTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: completedTasks.length * 72.0 + 16, // Fixed height for completed tasks
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        final todo = completedTasks[index];
                        final originalIndex = todos.indexWhere((t) => t.id == todo.id);
                        
                        return TodoItem(
                          todo: todo,
                          onToggle: () => onToggleTodo(originalIndex),
                          onDelete: () => onDeleteTodo(originalIndex),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 
