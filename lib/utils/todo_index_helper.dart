import '../models/todo.dart';

class TodoIndexHelper {
  /// Converts a filtered list index to the original list index
  static int convertToOriginalIndex(
    List<Todo> allTodos,
    List<Todo> filteredTodos,
    int filteredIndex,
  ) {
    final todo = filteredTodos[filteredIndex];
    return allTodos.indexWhere((t) => t.id == todo.id);
  }

  /// Calculates the reorder indices for moving a todo within the open tasks list
  static ReorderIndices calculateReorderIndices(
    List<Todo> allTodos,
    List<Todo> openTasks,
    int oldIndex,
    int newIndex,
  ) {
    final oldTodo = openTasks[oldIndex];
    final originalOldIndex = allTodos.indexWhere((t) => t.id == oldTodo.id);

    // Adjust newIndex for ReorderableListView behavior
    int adjustedNewIndex = newIndex;
    if (newIndex > oldIndex) {
      adjustedNewIndex--; // When moving down, newIndex is off by 1
    }

    // Calculate the new position in the original list
    int originalNewIndex;
    if (adjustedNewIndex >= openTasks.length) {
      // Moving to the end of open tasks
      originalNewIndex = allTodos.lastIndexWhere((t) => !t.isCompleted);
    } else {
      final newTodo = openTasks[adjustedNewIndex];
      originalNewIndex = allTodos.indexWhere((t) => t.id == newTodo.id);
    }

    return ReorderIndices(
      originalOldIndex: originalOldIndex,
      originalNewIndex: originalNewIndex,
    );
  }
}

class ReorderIndices {
  final int originalOldIndex;
  final int originalNewIndex;

  ReorderIndices({
    required this.originalOldIndex,
    required this.originalNewIndex,
  });
}