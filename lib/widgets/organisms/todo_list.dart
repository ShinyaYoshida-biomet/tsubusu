import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../models/animation_type.dart';
import '../atoms/completion_animation.dart';
import '../molecules/todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final List<Todo> originalTodos;
  final Map<String, AnimationController> animationControllers;
  final AnimationType animationType;
  final Function(int) onToggleTodo;
  final Function(int) onDeleteTodo;
  final bool allCompleted;

  const TodoList({
    super.key,
    required this.todos,
    required this.originalTodos,
    required this.animationControllers,
    required this.animationType,
    required this.onToggleTodo,
    required this.onDeleteTodo,
    required this.allCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              
              return TodoItem(
                todo: todo,
                onToggle: () => onToggleTodo(index),
                onDelete: () => onDeleteTodo(index),
              );
            },
          ),
          // Animations layer - always on top
          ...animationControllers.entries.map((entry) {
            final todoId = entry.key;
            final controller = entry.value;
            final todoIndex = todos.indexWhere((t) => t.id == todoId);
            
            if (todoIndex == -1) return const SizedBox.shrink();
            
            // Check if this is the animation for the task that completed all tasks
            final isLastToComplete = allCompleted;
            
            return Positioned(
              top: 8 + todoIndex * 72.0, // Approximate position of each todo item
              left: 8,
              right: 8,
              height: 64,
              child: IgnorePointer(
                child: CompletionAnimation(
                  animation: controller,
                  animationType: animationType,
                  isSpecial: isLastToComplete,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}