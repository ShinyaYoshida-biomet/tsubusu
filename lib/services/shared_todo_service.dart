import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class SharedTodoService extends ChangeNotifier {
  static SharedTodoService? _instance;
  static SharedTodoService get instance {
    _instance ??= SharedTodoService._internal();
    return _instance!;
  }

  SharedTodoService._internal() {
    _loadTodos();
  }

  @visibleForTesting
  static void reset() {
    _instance = null;
  }

  static const String _todosKey = 'shared_todos';
  List<Todo> _todos = [];

  List<Todo> get todos => List.unmodifiable(_todos);

  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_todosKey);
      
      if (todosJson != null) {
        final List<dynamic> todosList = jsonDecode(todosJson);
        _todos = todosList.map((json) => Todo.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load todos: $e');
    }
  }

  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
      await prefs.setString(_todosKey, todosJson);
    } catch (e) {
      debugPrint('Failed to save todos: $e');
    }
  }

  Future<void> addTodo(String text) async {
    if (text.trim().isEmpty) return;
    
    final todo = Todo(text: text.trim(), isCompleted: false);
    _todos.add(todo);
    notifyListeners();
    await _saveTodos();
  }

  Future<void> toggleTodo(int index) async {
    if (index >= 0 && index < _todos.length) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();
      await _saveTodos();
    }
  }

  Future<void> deleteTodo(int index) async {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
      notifyListeners();
      await _saveTodos();
    }
  }

  Future<void> reorderTodo(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Todo item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    notifyListeners();
    await _saveTodos();
  }

  /// Force refresh todos from storage (useful for window synchronization)
  Future<void> refresh() async {
    await _loadTodos();
  }
}