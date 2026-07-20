import 'package:flutter/foundation.dart';

import '../models/todo.dart';
import '../models/todo_list_id.dart';
import '../repositories/shared_preferences_todo_repository.dart';
import '../repositories/todo_repository.dart';

class TodoListService extends ChangeNotifier {
  final TodoListId listId;
  final TodoRepository _repository;
  List<Todo> _todos = [];
  late final Future<void> ready;
  var _isDisposed = false;

  TodoListService(this.listId, {TodoRepository? repository})
    : _repository = repository ?? SharedPreferencesTodoRepository() {
    ready = _loadTodos();
  }

  List<Todo> get todos => List.unmodifiable(_todos);

  Future<void> _loadTodos() async {
    try {
      await _repository.migrateLegacyWindowTodos();
      _todos = await _repository.loadTodos(listId);
      if (_isDisposed) {
        return;
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to load todos for list $listId: $error');
    }
  }

  Future<void> _saveTodos() async {
    try {
      await _repository.saveTodos(listId, _todos);
    } catch (error) {
      debugPrint('Failed to save todos for list $listId: $error');
    }
  }

  Future<void> addTodo(String text) async {
    if (text.trim().isEmpty) return;

    _todos.add(Todo(text: text.trim(), isCompleted: false));
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
    if (oldIndex < 0 ||
        oldIndex >= _todos.length ||
        newIndex < 0 ||
        newIndex > _todos.length) {
      return;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    notifyListeners();
    await _saveTodos();
  }

  Future<void> refresh() => _loadTodos();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
