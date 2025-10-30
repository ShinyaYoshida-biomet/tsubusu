class StorageKeys {
  static const String openWindows = 'open_windows';
  static const String selectedTheme = 'selected_theme';

  static String todosForWindow(String windowId) => 'todos_$windowId';
}