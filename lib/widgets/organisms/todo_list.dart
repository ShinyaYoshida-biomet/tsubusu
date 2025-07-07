import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../molecules/todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(int) onToggleTodo;
  final Function(int) onDeleteTodo;

  const TodoList({
    super.key,
    required this.todos,
    required this.onToggleTodo,
    required this.onDeleteTodo,
  });

  @override
  Widget build(BuildContext context) {
    final openTasks = todos.where((todo) => !todo.isCompleted).toList();
    final completedTasks = todos.where((todo) => todo.isCompleted).toList();
    
    return Expanded(
      child: Column(
        children: [
          // Open tasks section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: openTasks.length,
              itemBuilder: (context, index) {
                final todo = openTasks[index];
                final originalIndex = todos.indexWhere((t) => t.id == todo.id);
                
                return TodoItem(
                  todo: todo,
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
                color: Colors.grey[200],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Completed (${completedTasks.length})',
                      style: TextStyle(
                        color: Colors.grey[600],
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