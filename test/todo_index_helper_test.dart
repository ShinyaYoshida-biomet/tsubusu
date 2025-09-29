import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/models/todo.dart';
import 'package:tsubusu/utils/todo_index_helper.dart';

void main() {
  group('TodoIndexHelper', () {
    late List<Todo> allTodos;
    late List<Todo> openTodos;
    late List<Todo> completedTodos;

    setUp(() {
      // Create test data
      allTodos = [
        Todo(id: '1', text: 'Open Task 1', isCompleted: false),
        Todo(id: '2', text: 'Open Task 2', isCompleted: false),
        Todo(id: '3', text: 'Completed Task 1', isCompleted: true),
        Todo(id: '4', text: 'Open Task 3', isCompleted: false),
        Todo(id: '5', text: 'Completed Task 2', isCompleted: true),
      ];

      openTodos = allTodos.where((t) => !t.isCompleted).toList();
      completedTodos = allTodos.where((t) => t.isCompleted).toList();
    });

    group('convertToOriginalIndex', () {
      test('should convert filtered index to original index for open tasks', () {
        // Open tasks: index 0, 1, 2 in filtered list
        // Correspond to: index 0, 1, 3 in original list
        expect(TodoIndexHelper.convertToOriginalIndex(allTodos, openTodos, 0), 0);
        expect(TodoIndexHelper.convertToOriginalIndex(allTodos, openTodos, 1), 1);
        expect(TodoIndexHelper.convertToOriginalIndex(allTodos, openTodos, 2), 3);
      });

      test('should convert filtered index to original index for completed tasks', () {
        // Completed tasks: index 0, 1 in filtered list
        // Correspond to: index 2, 4 in original list
        expect(TodoIndexHelper.convertToOriginalIndex(allTodos, completedTodos, 0), 2);
        expect(TodoIndexHelper.convertToOriginalIndex(allTodos, completedTodos, 1), 4);
      });

      test('should handle edge case with single item', () {
        final singleTodo = [allTodos[0]];
        expect(TodoIndexHelper.convertToOriginalIndex(allTodos, singleTodo, 0), 0);
      });
    });

    group('calculateReorderIndices', () {
      test('should calculate indices when moving down', () {
        // Move first open task (index 0) to position 2
        final result = TodoIndexHelper.calculateReorderIndices(
          allTodos,
          openTodos,
          0, // old index in open list
          2, // new index in open list
        );

        expect(result.originalOldIndex, 0); // index 0 in all todos
        expect(result.originalNewIndex, 1); // should adjust for ReorderableListView behavior
      });

      test('should calculate indices when moving up', () {
        // Move last open task (index 2) to position 0
        final result = TodoIndexHelper.calculateReorderIndices(
          allTodos,
          openTodos,
          2, // old index in open list (Open Task 3)
          0, // new index in open list
        );

        expect(result.originalOldIndex, 3); // index 3 in all todos
        expect(result.originalNewIndex, 0); // index 0 in all todos
      });

      test('should handle moving to middle position', () {
        // Move second open task (index 1) to last position (index 2)
        final result = TodoIndexHelper.calculateReorderIndices(
          allTodos,
          openTodos,
          1, // old index
          3, // new index (beyond list, should go to end)
        );

        expect(result.originalOldIndex, 1);
        expect(result.originalNewIndex, 3); // last open task index in all todos
      });

      test('should handle adjacent swap', () {
        // Swap first two items (move item at index 0 to index 1)
        final result = TodoIndexHelper.calculateReorderIndices(
          allTodos,
          openTodos,
          0,
          1,
        );

        expect(result.originalOldIndex, 0);
        // After adjustment, it should be 0 (newIndex - 1 when moving down)
        expect(result.originalNewIndex, 0);
      });
    });
  });
}