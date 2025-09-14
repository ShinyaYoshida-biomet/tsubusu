import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo.dart';
import '../../providers/theme_provider.dart';
import '../molecules/todo_item.dart';

class TodoList extends StatefulWidget {
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
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  double _completedSectionHeight = 200.0; // Default height
  final double _minCompletedHeight = 80.0;
  final double _maxCompletedHeight = 400.0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final openTasks = widget.todos.where((todo) => !todo.isCompleted).toList();
    final completedTasks = widget.todos.where((todo) => todo.isCompleted).toList();
    
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
                if (widget.onReorderTodo != null) {
                  // Convert open task indices to original todo list indices
                  final oldTodo = openTasks[oldIndex];
                  final originalOldIndex = widget.todos.indexWhere((t) => t.id == oldTodo.id);
                  
                  // Adjust newIndex for ReorderableListView behavior
                  if (newIndex > oldIndex) {
                    newIndex--; // When moving down, newIndex is off by 1
                  }
                  
                  // Calculate the new position in the original list
                  int originalNewIndex;
                  if (newIndex >= openTasks.length) {
                    // Moving to the end of open tasks
                    originalNewIndex = widget.todos.lastIndexWhere((t) => !t.isCompleted);
                  } else {
                    final newTodo = openTasks[newIndex];
                    originalNewIndex = widget.todos.indexWhere((t) => t.id == newTodo.id);
                  }
                  
                  widget.onReorderTodo!(originalOldIndex, originalNewIndex);
                }
              },
              itemBuilder: (context, index) {
                final todo = openTasks[index];
                final originalIndex = widget.todos.indexWhere((t) => t.id == todo.id);
                
                return TodoItem(
                  key: ValueKey(todo.id),
                  todo: todo,
                  reorderIndex: index,
                  onToggle: () => widget.onToggleTodo(originalIndex),
                  onDelete: () => widget.onDeleteTodo(originalIndex),
                );
              },
            ),
          ),
          
          // Completed tasks section - at the bottom with resizable divider
          if (completedTasks.isNotEmpty)
            Column(
              children: [
                // Resizable divider
                MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _completedSectionHeight = (_completedSectionHeight - details.delta.dy)
                            .clamp(_minCompletedHeight, _maxCompletedHeight);
                      });
                    },
                    child: Container(
                      height: 8,
                      color: themeProvider.borderColor,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: themeProvider.completedTextColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Completed tasks container
                Container(
                  height: _completedSectionHeight,
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
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: completedTasks.length,
                          itemBuilder: (context, index) {
                            final todo = completedTasks[index];
                            final originalIndex = widget.todos.indexWhere((t) => t.id == todo.id);
                            
                            return TodoItem(
                              todo: todo,
                              onToggle: () => widget.onToggleTodo(originalIndex),
                              onDelete: () => widget.onDeleteTodo(originalIndex),
                              isCompleted: true, // Mark as completed section
                            );
                          },
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
} 
