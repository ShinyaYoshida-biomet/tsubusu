
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/models/todo.dart';
import 'package:tsubusu/services/shared_todo_service.dart';
import 'package:tsubusu/services/window_todo_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedTodoService', () {
    late SharedTodoService sharedTodoService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      SharedTodoService.reset();
      sharedTodoService = SharedTodoService.instance;
      await sharedTodoService.addTodo('Todo 1');
      await sharedTodoService.addTodo('Todo 2');
      await sharedTodoService.addTodo('Todo 3');
    });

    test('reorderTodo should correctly reorder todos when moving down', () async {
      // Act
      await sharedTodoService.reorderTodo(0, 3);

      // Assert
      expect(sharedTodoService.todos[0].text, 'Todo 2');
      expect(sharedTodoService.todos[1].text, 'Todo 3');
      expect(sharedTodoService.todos[2].text, 'Todo 1');
    });

    test('reorderTodo should correctly reorder todos when moving up', () async {
      // Act
      await sharedTodoService.reorderTodo(2, 0);

      // Assert
      expect(sharedTodoService.todos[0].text, 'Todo 3');
      expect(sharedTodoService.todos[1].text, 'Todo 1');
      expect(sharedTodoService.todos[2].text, 'Todo 2');
    });
  });

  group('WindowTodoService', () {
    late WindowTodoService windowTodoService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      windowTodoService = WindowTodoService('test_window');
      await windowTodoService.addTodo('Todo 1');
      await windowTodoService.addTodo('Todo 2');
      await windowTodoService.addTodo('Todo 3');
    });

    test('reorderTodo should correctly reorder todos when moving down', () async {
      // Act
      await windowTodoService.reorderTodo(0, 3);

      // Assert
      expect(windowTodoService.todos[0].text, 'Todo 2');
      expect(windowTodoService.todos[1].text, 'Todo 3');
      expect(windowTodoService.todos[2].text, 'Todo 1');
    });

    test('reorderTodo should correctly reorder todos when moving up', () async {
      // Act
      await windowTodoService.reorderTodo(2, 0);

      // Assert
      expect(windowTodoService.todos[0].text, 'Todo 3');
      expect(windowTodoService.todos[1].text, 'Todo 1');
      expect(windowTodoService.todos[2].text, 'Todo 2');
    });
  });
}
