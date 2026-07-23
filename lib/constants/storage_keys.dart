import '../models/todo_list_id.dart';

class StorageKeys {
  static const String todoListCatalog = 'todo_list_catalog';
  static const String openListIds = 'open_list_ids';
  static const String selectedTheme = 'selected_theme';

  /// Prefix used by releases before the todo-list persistence boundary.
  static const String legacyWindowTodosPrefix = 'todos_window_';

  static String todosForList(TodoListId listId) => 'todos_list_${listId.value}';
}
