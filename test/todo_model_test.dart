import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/models/todo.dart';

void main() {
  group('Todo', () {
    group('constructor', () {
      test('should create todo with required fields', () {
        final todo = Todo(text: 'Test Task', isCompleted: false);

        expect(todo.text, 'Test Task');
        expect(todo.isCompleted, false);
        expect(todo.id, isNotEmpty);
      });

      test('should generate unique IDs', () async {
        final todo1 = Todo(text: 'Task 1', isCompleted: false);
        // Add small delay to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 1));
        final todo2 = Todo(text: 'Task 2', isCompleted: false);

        expect(todo1.id, isNot(equals(todo2.id)));
      });

      test('should accept custom ID', () {
        final todo = Todo(text: 'Test Task', isCompleted: false, id: 'custom_id');

        expect(todo.id, 'custom_id');
      });

      test('should create completed todo', () {
        final todo = Todo(text: 'Done Task', isCompleted: true);

        expect(todo.isCompleted, true);
      });
    });

    group('copyWith', () {
      late Todo originalTodo;

      setUp(() {
        originalTodo = Todo(text: 'Original', isCompleted: false, id: 'test_id');
      });

      test('should copy with new text', () {
        final copied = originalTodo.copyWith(text: 'Modified');

        expect(copied.text, 'Modified');
        expect(copied.isCompleted, originalTodo.isCompleted);
        expect(copied.id, originalTodo.id);
      });

      test('should copy with new isCompleted', () {
        final copied = originalTodo.copyWith(isCompleted: true);

        expect(copied.text, originalTodo.text);
        expect(copied.isCompleted, true);
        expect(copied.id, originalTodo.id);
      });

      test('should copy with new id', () {
        final copied = originalTodo.copyWith(id: 'new_id');

        expect(copied.text, originalTodo.text);
        expect(copied.isCompleted, originalTodo.isCompleted);
        expect(copied.id, 'new_id');
      });

      test('should copy with all new fields', () {
        final copied = originalTodo.copyWith(
          text: 'New Text',
          isCompleted: true,
          id: 'new_id',
        );

        expect(copied.text, 'New Text');
        expect(copied.isCompleted, true);
        expect(copied.id, 'new_id');
      });

      test('should preserve original when no fields specified', () {
        final copied = originalTodo.copyWith();

        expect(copied.text, originalTodo.text);
        expect(copied.isCompleted, originalTodo.isCompleted);
        expect(copied.id, originalTodo.id);
      });

      test('original todo should remain unchanged', () {
        final originalText = originalTodo.text;
        final originalCompleted = originalTodo.isCompleted;
        final originalId = originalTodo.id;

        originalTodo.copyWith(text: 'Modified', isCompleted: true);

        expect(originalTodo.text, originalText);
        expect(originalTodo.isCompleted, originalCompleted);
        expect(originalTodo.id, originalId);
      });
    });

    group('toJson', () {
      test('should convert todo to JSON', () {
        final todo = Todo(text: 'Test Task', isCompleted: false, id: 'test_id');
        final json = todo.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['text'], 'Test Task');
        expect(json['isCompleted'], false);
        expect(json['id'], 'test_id');
      });

      test('should convert completed todo to JSON', () {
        final todo = Todo(text: 'Done', isCompleted: true, id: '123');
        final json = todo.toJson();

        expect(json['isCompleted'], true);
      });

      test('should include all required fields', () {
        final todo = Todo(text: 'Task', isCompleted: false);
        final json = todo.toJson();

        expect(json.containsKey('text'), true);
        expect(json.containsKey('isCompleted'), true);
        expect(json.containsKey('id'), true);
      });
    });

    group('fromJson', () {
      test('should create todo from JSON', () {
        final json = {
          'text': 'Test Task',
          'isCompleted': false,
          'id': 'test_id',
        };

        final todo = Todo.fromJson(json);

        expect(todo.text, 'Test Task');
        expect(todo.isCompleted, false);
        expect(todo.id, 'test_id');
      });

      test('should create completed todo from JSON', () {
        final json = {
          'text': 'Done Task',
          'isCompleted': true,
          'id': 'done_id',
        };

        final todo = Todo.fromJson(json);

        expect(todo.isCompleted, true);
      });

      test('should handle special characters in text', () {
        final json = {
          'text': 'Task with "quotes" and \\backslash',
          'isCompleted': false,
          'id': 'special',
        };

        final todo = Todo.fromJson(json);

        expect(todo.text, contains('"quotes"'));
      });
    });

    group('JSON round-trip', () {
      test('should preserve data through toJson and fromJson', () {
        final original = Todo(text: 'Round Trip', isCompleted: true, id: 'round_trip');
        final json = original.toJson();
        final restored = Todo.fromJson(json);

        expect(restored.text, original.text);
        expect(restored.isCompleted, original.isCompleted);
        expect(restored.id, original.id);
      });

      test('should handle multiple round-trips', () {
        var todo = Todo(text: 'Multiple', isCompleted: false, id: 'multi');

        for (var i = 0; i < 3; i++) {
          final json = todo.toJson();
          todo = Todo.fromJson(json);
        }

        expect(todo.text, 'Multiple');
        expect(todo.isCompleted, false);
        expect(todo.id, 'multi');
      });
    });

    group('edge cases', () {
      test('should handle empty text', () {
        final todo = Todo(text: '', isCompleted: false);
        expect(todo.text, '');
      });

      test('should handle very long text', () {
        final longText = 'a' * 1000;
        final todo = Todo(text: longText, isCompleted: false);
        expect(todo.text, longText);
      });

      test('should handle unicode characters', () {
        final todo = Todo(text: '日本語タスク 🎉', isCompleted: false);
        expect(todo.text, '日本語タスク 🎉');

        final json = todo.toJson();
        final restored = Todo.fromJson(json);
        expect(restored.text, '日本語タスク 🎉');
      });
    });
  });
}