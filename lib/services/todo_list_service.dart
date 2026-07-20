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

  Todo? todoById(String id) {
    for (final todo in _todos) {
      if (todo.id == id) return todo;
    }
    return null;
  }

  List<Todo> childrenOf(String parentId) =>
      List.unmodifiable(_todos.where((todo) => todo.parentId == parentId));

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

  Future<void> addSubtask(String parentId, String text) async {
    if (text.trim().isEmpty || todoById(parentId) == null) return;

    final parent = todoById(parentId)!;
    final child = Todo(
      text: text.trim(),
      isCompleted: false,
      parentId: parentId,
    );
    final siblingIndexes = [
      for (var i = 0; i < _todos.length; i++)
        if (_todos[i].parentId == parentId) i,
    ];
    final insertAt =
        siblingIndexes.isEmpty
            ? _todos.indexOf(parent) + 1
            : siblingIndexes.last + 1;
    _todos.insert(insertAt, child);
    parent.isCompleted = false;
    notifyListeners();
    await _saveTodos();
  }

  Future<void> updateTodoText(String id, String text) async {
    final todo = todoById(id);
    if (todo == null || text.trim().isEmpty) return;
    todo.text = text.trim();
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

  Future<void> toggleTodoById(String id) async {
    final todo = todoById(id);
    if (todo == null) return;

    final nextValue = !todo.isCompleted;
    final descendants =
        _todos.where((candidate) => candidate.parentId == id).toList();
    todo.isCompleted = nextValue;
    if (descendants.isNotEmpty) {
      for (final child in descendants) {
        child.isCompleted = nextValue;
      }
    } else if (todo.parentId != null) {
      _syncParentCompletion(todo.parentId!);
    }
    notifyListeners();
    await _saveTodos();
  }

  void _syncParentCompletion(String parentId) {
    final parent = todoById(parentId);
    final children = childrenOf(parentId);
    if (parent == null || children.isEmpty) return;
    parent.isCompleted = children.every((child) => child.isCompleted);
  }

  Future<void> deleteTodo(int index) async {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
      notifyListeners();
      await _saveTodos();
    }
  }

  Future<void> deleteTodoById(String id) async {
    if (todoById(id) == null) return;
    final idsToDelete = <String>{id};
    for (final todo in _todos) {
      if (todo.parentId == id) idsToDelete.add(todo.id);
    }
    _todos.removeWhere((todo) => idsToDelete.contains(todo.id));
    notifyListeners();
    await _saveTodos();
  }

  Future<void> reorderSiblings(
    String? parentId,
    int oldIndex,
    int newIndex,
  ) async {
    final siblings = _todos.where((todo) => todo.parentId == parentId).toList();
    if (oldIndex < 0 ||
        oldIndex >= siblings.length ||
        newIndex < 0 ||
        newIndex > siblings.length) {
      return;
    }
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final moved = siblings.removeAt(oldIndex);
    siblings.insert(newIndex, moved);
    final siblingIds = siblings.map((todo) => todo.id).toSet();
    var siblingCursor = 0;
    for (var i = 0; i < _todos.length; i++) {
      if (siblingIds.contains(_todos[i].id)) {
        _todos[i] = siblings[siblingCursor++];
      }
    }
    notifyListeners();
    await _saveTodos();
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
