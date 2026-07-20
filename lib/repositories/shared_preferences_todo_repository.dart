import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../models/todo.dart';
import '../models/todo_list_id.dart';
import 'todo_repository.dart';

class SharedPreferencesTodoRepository implements TodoRepository {
  @override
  Future<List<Todo>> loadTodos(TodoListId listId) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(StorageKeys.todosForList(listId));

    if (todosJson == null) {
      return [];
    }

    final todosList = jsonDecode(todosJson) as List<dynamic>;
    return todosList
        .map((json) => Todo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTodos(TodoListId listId, List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = jsonEncode(todos.map((todo) => todo.toJson()).toList());
    await prefs.setString(StorageKeys.todosForList(listId), todosJson);
  }

  @override
  Future<void> migrateLegacyWindowTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyKeys = prefs.getKeys().where(
      (key) => key.startsWith(StorageKeys.legacyWindowTodosPrefix),
    );

    for (final legacyKey in legacyKeys) {
      final legacyWindowSuffix = legacyKey.substring(
        StorageKeys.legacyWindowTodosPrefix.length,
      );
      // Before #31 the key was built as `todos_$windowId`, where windowId was
      // itself `window_<timestamp>`. The prefix therefore includes the first
      // `window_`; restore it before deriving the stable domain list ID.
      final legacyWindowId = 'window_$legacyWindowSuffix';
      final listId = TodoListId.fromLegacyWindowId(legacyWindowId);
      final listKey = StorageKeys.todosForList(listId);

      // Do not overwrite a list that was already imported or subsequently
      // updated. The old key stays in place as a recoverable backup.
      if (prefs.containsKey(listKey)) {
        continue;
      }

      final legacyTodos = prefs.getString(legacyKey);
      if (legacyTodos != null) {
        await prefs.setString(listKey, legacyTodos);
      }
    }
  }
}
