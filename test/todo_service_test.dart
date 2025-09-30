import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/services/window_todo_service.dart';
import 'package:tsubusu/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WindowTodoService', () {
    late WindowTodoService windowTodoService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      windowTodoService = WindowTodoService('test_window');
      await Future.delayed(const Duration(milliseconds: 100));
    });

    group('addTodo', () {
      test('should add a todo to the list', () async {
        await windowTodoService.addTodo('New Task');

        expect(windowTodoService.todos.length, 1);
        expect(windowTodoService.todos[0].text, 'New Task');
        expect(windowTodoService.todos[0].isCompleted, false);
      });

      test('should trim whitespace from text', () async {
        await windowTodoService.addTodo('  Spaced Task  ');

        expect(windowTodoService.todos[0].text, 'Spaced Task');
      });

      test('should not add empty todos', () async {
        await windowTodoService.addTodo('');

        expect(windowTodoService.todos.length, 0);
      });

      test('should not add whitespace-only todos', () async {
        await windowTodoService.addTodo('   ');

        expect(windowTodoService.todos.length, 0);
      });

      test('should add multiple todos', () async {
        await windowTodoService.addTodo('Task 1');
        await windowTodoService.addTodo('Task 2');
        await windowTodoService.addTodo('Task 3');

        expect(windowTodoService.todos.length, 3);
        expect(windowTodoService.todos[0].text, 'Task 1');
        expect(windowTodoService.todos[1].text, 'Task 2');
        expect(windowTodoService.todos[2].text, 'Task 3');
      });

      test('should persist todos to SharedPreferences', () async {
        await windowTodoService.addTodo('Persisted Task');

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('todos_window_test_window');

        expect(savedData, isNotNull);
        expect(savedData, contains('Persisted Task'));
      });
    });

    group('toggleTodo', () {
      setUp(() async {
        await windowTodoService.addTodo('Task 1');
        await windowTodoService.addTodo('Task 2');
      });

      test('should toggle todo from incomplete to complete', () async {
        await windowTodoService.toggleTodo(0);

        expect(windowTodoService.todos[0].isCompleted, true);
      });

      test('should toggle todo from complete to incomplete', () async {
        await windowTodoService.toggleTodo(0);
        await windowTodoService.toggleTodo(0);

        expect(windowTodoService.todos[0].isCompleted, false);
      });

      test('should only toggle specified todo', () async {
        await windowTodoService.toggleTodo(0);

        expect(windowTodoService.todos[0].isCompleted, true);
        expect(windowTodoService.todos[1].isCompleted, false);
      });

      test('should handle invalid index gracefully', () async {
        await windowTodoService.toggleTodo(99);

        // Should not throw, todos should remain unchanged
        expect(windowTodoService.todos.length, 2);
      });

      test('should persist toggle to SharedPreferences', () async {
        await windowTodoService.toggleTodo(0);

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('todos_window_test_window');

        expect(savedData, contains('"isCompleted":true'));
      });
    });

    group('deleteTodo', () {
      setUp(() async {
        await windowTodoService.addTodo('Task 1');
        await windowTodoService.addTodo('Task 2');
        await windowTodoService.addTodo('Task 3');
      });

      test('should delete todo at specified index', () async {
        await windowTodoService.deleteTodo(1);

        expect(windowTodoService.todos.length, 2);
        expect(windowTodoService.todos[0].text, 'Task 1');
        expect(windowTodoService.todos[1].text, 'Task 3');
      });

      test('should delete first todo', () async {
        await windowTodoService.deleteTodo(0);

        expect(windowTodoService.todos.length, 2);
        expect(windowTodoService.todos[0].text, 'Task 2');
      });

      test('should delete last todo', () async {
        await windowTodoService.deleteTodo(2);

        expect(windowTodoService.todos.length, 2);
        expect(windowTodoService.todos[1].text, 'Task 2');
      });

      test('should handle invalid index gracefully', () async {
        await windowTodoService.deleteTodo(99);

        expect(windowTodoService.todos.length, 3);
      });

      test('should persist deletion to SharedPreferences', () async {
        await windowTodoService.deleteTodo(1);

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('todos_window_test_window');

        expect(savedData, isNot(contains('Task 2')));
      });
    });

    group('reorderTodo', () {
      setUp(() async {
        await windowTodoService.addTodo('Todo 1');
        await windowTodoService.addTodo('Todo 2');
        await windowTodoService.addTodo('Todo 3');
      });

      test('should correctly reorder todos when moving down', () async {
        await windowTodoService.reorderTodo(0, 3);

        expect(windowTodoService.todos[0].text, 'Todo 2');
        expect(windowTodoService.todos[1].text, 'Todo 3');
        expect(windowTodoService.todos[2].text, 'Todo 1');
      });

      test('should correctly reorder todos when moving up', () async {
        await windowTodoService.reorderTodo(2, 0);

        expect(windowTodoService.todos[0].text, 'Todo 3');
        expect(windowTodoService.todos[1].text, 'Todo 1');
        expect(windowTodoService.todos[2].text, 'Todo 2');
      });

      test('should handle adjacent swap', () async {
        await windowTodoService.reorderTodo(0, 1);

        // After reordering with newIndex adjusted (-1 when moving down)
        // The list stays the same when oldIndex=0, newIndex=1 becomes 0
        expect(windowTodoService.todos[0].text, 'Todo 1');
        expect(windowTodoService.todos[1].text, 'Todo 2');
        expect(windowTodoService.todos[2].text, 'Todo 3');
      });

      test('should persist reorder to SharedPreferences', () async {
        await windowTodoService.reorderTodo(0, 3);

        final prefs = await SharedPreferences.getInstance();
        final savedData = prefs.getString('todos_window_test_window');

        expect(savedData, isNotNull);
      });
    });

    group('refresh', () {
      test('should reload todos from SharedPreferences', () async {
        await windowTodoService.addTodo('Initial Task');

        // Manually update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('todos_window_test_window',
          '[{"id":"1","text":"External Task","isCompleted":false}]');

        await windowTodoService.refresh();

        expect(windowTodoService.todos.length, 1);
        expect(windowTodoService.todos[0].text, 'External Task');
      });

      test('should handle empty storage', () async {
        await windowTodoService.addTodo('Task');

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('todos_window_test_window');

        await windowTodoService.refresh();

        expect(windowTodoService.todos.length, 0);
      });
    });

    group('todos getter', () {
      test('should return unmodifiable list', () async {
        await windowTodoService.addTodo('Task');

        final todos = windowTodoService.todos;

        expect(() => todos.add(Todo(text: 'Test', isCompleted: false)), throwsUnsupportedError);
      });

      test('should return current todos', () async {
        expect(windowTodoService.todos.length, 0);

        await windowTodoService.addTodo('Task 1');
        expect(windowTodoService.todos.length, 1);

        await windowTodoService.addTodo('Task 2');
        expect(windowTodoService.todos.length, 2);
      });
    });

    group('persistence', () {
      test('should load existing todos on initialization', () async {
        // Setup existing data
        SharedPreferences.setMockInitialValues({
          'todos_window_persist_test': '[{"id":"1","text":"Existing Task","isCompleted":true}]'
        });

        final service = WindowTodoService('persist_test');
        await Future.delayed(const Duration(milliseconds: 100));

        expect(service.todos.length, 1);
        expect(service.todos[0].text, 'Existing Task');
        expect(service.todos[0].isCompleted, true);
      });

      test('should use unique storage key per window', () async {
        final service1 = WindowTodoService('window_1');
        final service2 = WindowTodoService('window_2');
        await Future.delayed(const Duration(milliseconds: 100));

        await service1.addTodo('Window 1 Task');
        await service2.addTodo('Window 2 Task');

        expect(service1.todos[0].text, 'Window 1 Task');
        expect(service2.todos[0].text, 'Window 2 Task');
      });
    });
  });
}