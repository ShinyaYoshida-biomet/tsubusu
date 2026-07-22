import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsubusu/models/todo.dart';
import 'package:tsubusu/models/todo_list_id.dart';
import 'package:tsubusu/repositories/shared_preferences_todo_repository.dart';
import 'package:tsubusu/services/todo_list_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TodoListService', () {
    late TodoListService todoListService;
    late TodoListId listId;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      listId = TodoListId.create();
      todoListService = TodoListService(listId);
      await todoListService.ready;
    });

    test('adds trimmed todos and persists them by logical list ID', () async {
      await todoListService.addTodo('  New task  ');

      expect(todoListService.todos.single.text, 'New task');
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('todos_list_${listId.value}'),
        contains('New task'),
      );
    });

    test('does not add empty todos', () async {
      await todoListService.addTodo('   ');

      expect(todoListService.todos, isEmpty);
    });

    test('edits and persists a todo title by ID', () async {
      await todoListService.addTodo('Original title');
      final todoId = todoListService.todos.single.id;

      await todoListService.updateTodoText(todoId, '  Updated title  ');

      expect(todoListService.todoById(todoId)!.text, 'Updated title');
      final reloadedService = TodoListService(listId);
      await reloadedService.ready;
      expect(reloadedService.todoById(todoId)!.text, 'Updated title');
    });

    test('does not replace a title with blank text', () async {
      await todoListService.addTodo('Keep this title');
      final todoId = todoListService.todos.single.id;

      await todoListService.updateTodoText(todoId, '   ');

      expect(todoListService.todoById(todoId)!.text, 'Keep this title');
    });

    test('toggles, deletes, and reorders todos', () async {
      await todoListService.addTodo('First');
      await todoListService.addTodo('Second');
      await todoListService.addTodo('Third');

      await todoListService.toggleTodo(1);
      await todoListService.reorderTodo(0, 3);
      await todoListService.deleteTodo(1);

      expect(todoListService.todos.map((todo) => todo.text), [
        'Second',
        'First',
      ]);
      expect(todoListService.todos.first.isCompleted, isTrue);
    });

    test('supports subtasks and parent completion rules', () async {
      await todoListService.addTodo('Project');
      final parent = todoListService.todos.single;

      await todoListService.addSubtask(parent.id, 'Design');
      await todoListService.addSubtask(parent.id, 'Build');
      final children = todoListService.childrenOf(parent.id);

      expect(children, hasLength(2));
      expect(children.every((todo) => todo.parentId == parent.id), isTrue);

      await todoListService.toggleTodoById(children.first.id);
      expect(todoListService.todoById(parent.id)!.isCompleted, isFalse);

      await todoListService.toggleTodoById(children.last.id);
      expect(todoListService.todoById(parent.id)!.isCompleted, isTrue);

      await todoListService.toggleTodoById(parent.id);
      expect(
        todoListService
            .childrenOf(parent.id)
            .every((todo) => !todo.isCompleted),
        isTrue,
      );
      expect(todoListService.todoById(parent.id)!.isCompleted, isFalse);
    });

    test('adds one subtask exactly once', () async {
      await todoListService.addTodo('Project');
      final parent = todoListService.todos.single;

      await todoListService.addSubtask(parent.id, 'Single child');

      expect(todoListService.childrenOf(parent.id), hasLength(1));
      expect(todoListService.childrenOf(parent.id).single.text, 'Single child');
    });

    test('deleting a parent deletes its subtasks', () async {
      await todoListService.addTodo('Project');
      final parent = todoListService.todos.single;
      await todoListService.addSubtask(parent.id, 'Child');

      await todoListService.deleteTodoById(parent.id);

      expect(todoListService.todos, isEmpty);
    });

    test('adding a subtask reopens a completed parent', () async {
      await todoListService.addTodo('Project');
      final parent = todoListService.todos.single;
      await todoListService.addSubtask(parent.id, 'Child');
      final child = todoListService.childrenOf(parent.id).single;
      await todoListService.toggleTodoById(child.id);
      expect(todoListService.todoById(parent.id)!.isCompleted, isTrue);

      await todoListService.addSubtask(parent.id, 'New child');

      expect(todoListService.todoById(parent.id)!.isCompleted, isFalse);
      expect(todoListService.childrenOf(parent.id), hasLength(2));
    });

    test('keeps lists isolated without referring to desktop windows', () async {
      final anotherList = TodoListService(TodoListId.create());
      await anotherList.ready;

      await todoListService.addTodo('First list task');
      await anotherList.addTodo('Second list task');

      expect(todoListService.todos.single.text, 'First list task');
      expect(anotherList.todos.single.text, 'Second list task');
    });

    test('loads an existing logical list', () async {
      final existingList = TodoListId.create();
      SharedPreferences.setMockInitialValues({
        'todos_list_${existingList.value}':
            '[{"id":"1","text":"Existing task","isCompleted":true}]',
      });

      final service = TodoListService(existingList);
      await service.ready;

      expect(service.todos.single.text, 'Existing task');
      expect(service.todos.single.isCompleted, isTrue);
    });

    test('returns an unmodifiable todo list', () async {
      await todoListService.addTodo('Task');

      expect(
        () =>
            todoListService.todos.add(Todo(text: 'Other', isCompleted: false)),
        throwsUnsupportedError,
      );
    });
  });

  group('SharedPreferencesTodoRepository migration', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'copies legacy window-keyed todos to their domain list without deletion',
      () async {
        const legacyWindowId = 'window_123';
        const legacyKey = 'todos_$legacyWindowId';
        const legacyTodos =
            '[{"id":"1","text":"Migrated task","isCompleted":false}]';
        SharedPreferences.setMockInitialValues({legacyKey: legacyTodos});

        final repository = SharedPreferencesTodoRepository();
        await repository.migrateLegacyWindowTodos();

        final prefs = await SharedPreferences.getInstance();
        final migratedId = TodoListId.fromLegacyWindowId(legacyWindowId);
        expect(migratedId.value, 'legacy_window_123');
        expect(prefs.getString(legacyKey), legacyTodos);
        expect(prefs.getString('todos_list_${migratedId.value}'), legacyTodos);
        expect(
          (await repository.loadTodos(migratedId)).single.text,
          'Migrated task',
        );
      },
    );

    test('does not overwrite an already migrated list', () async {
      SharedPreferences.setMockInitialValues({
        'todos_window_123': '[{"id":"1","text":"Legacy","isCompleted":false}]',
        'todos_list_legacy_window_123':
            '[{"id":"2","text":"Current","isCompleted":false}]',
      });

      final repository = SharedPreferencesTodoRepository();
      await repository.migrateLegacyWindowTodos();

      final todos = await repository.loadTodos(
        TodoListId.fromLegacyWindowId('window_123'),
      );
      expect(todos.single.text, 'Current');
    });
  });
}
