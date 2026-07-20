import '../models/todo.dart';
import '../models/todo_list_id.dart';

/// Persistence boundary for logical todo lists.
///
/// Implementations must be addressed by [TodoListId], never by UI or OS
/// window identifiers, so the same domain data can be presented on desktop or
/// mobile.
abstract interface class TodoRepository {
  Future<List<Todo>> loadTodos(TodoListId listId);

  Future<void> saveTodos(TodoListId listId, List<Todo> todos);

  /// Copies data saved by releases before #31 into list-addressed storage.
  ///
  /// The source keys are intentionally retained. This makes the migration
  /// repeatable and prevents a failed or interrupted upgrade from losing data.
  Future<void> migrateLegacyWindowTodos();
}
