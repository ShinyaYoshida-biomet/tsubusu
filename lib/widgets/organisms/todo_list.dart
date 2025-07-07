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
  final Function(int, int) onReorderTodo;
  final bool allCompleted;

  const TodoList({
    super.key,
    required this.todos,
    required this.originalTodos,
    required this.animationControllers,
    required this.animationType,
    required this.onToggleTodo,
    required this.onDeleteTodo,
    required this.onReorderTodo,
    required this.allCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final openTasks = todos.where((todo) => !todo.isCompleted).toList();
    final completedTasks = todos.where((todo) => todo.isCompleted).toList();
    
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none, // Allow animations to overflow
        children: [
          Column(
            children: [
              // Open tasks section
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: openTasks.length,
                  buildDefaultDragHandles: false, // Disable default drag handles
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final oldOriginalIndex = todos.indexWhere((t) => t.id == openTasks[oldIndex].id);
                    final newOriginalIndex = todos.indexWhere((t) => t.id == openTasks[newIndex].id);
                    onReorderTodo(oldOriginalIndex, newOriginalIndex);
                  },
                  itemBuilder: (context, index) {
                    final todo = openTasks[index];
                    final originalIndex = todos.indexWhere((t) => t.id == todo.id);
                    
                    return TodoItem(
                      key: ValueKey(todo.id),
                      todo: todo,
                      onToggle: () => onToggleTodo(originalIndex),
                      onDelete: () => onDeleteTodo(originalIndex),
                      reorderIndex: index, // Pass the index for drag handle
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
          
          // Animations layer - always on top
          ...animationControllers.entries.map((entry) {
            final todoId = entry.key;
            final controller = entry.value;
            
            // Find the todo in the original todos list to determine where it should animate
            final originalTodo = originalTodos.firstWhere((t) => t.id == todoId, orElse: () => throw StateError('Todo $todoId not found'));
            
            double? animationTop;
            
            if (!originalTodo.isCompleted) {
              // Task is still in open section (animation is playing before it moves)
              final openIndex = openTasks.indexWhere((t) => t.id == todoId);
              if (openIndex != -1) {
                animationTop = 8 + openIndex * 72.0;
              }
            } else {
              // Task has moved to completed section
              final completedIndex = completedTasks.indexWhere((t) => t.id == todoId);
              if (completedIndex != -1) {
                // Calculate position in completed section
                final completedSectionTop = MediaQuery.of(context).size.height - 
                    (completedTasks.length * 72.0 + 50); // 50 for header + padding
                animationTop = completedSectionTop + 40 + 8 + completedIndex * 72.0;
              }
            }
            
            if (animationTop == null || animationTop < 0) {
              return const SizedBox.shrink();
            }
            
            // Check if this is the animation for the task that completed all tasks
            final isLastToComplete = allCompleted;
            
            return Positioned(
              top: animationTop,
              left: 0,
              right: 0,
              height: 120, // Increase height to ensure animation is visible
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