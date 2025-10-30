class StorageKeys {
  static const String openWindows = 'open_windows';
  static const String selectedTheme = 'selected_theme';
  static const String nextWindowCounter = 'next_window_counter';

  static String todosForWindow(String windowId) => 'todos_window_$windowId';
}