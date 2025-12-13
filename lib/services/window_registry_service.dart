import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class WindowRegistryService {
  /// Gets a unique window ID using timestamp
  /// This ensures each new window gets a truly unique ID and never reuses old window data
  /// Format: window_[timestamp]
  static Future<String> getNextAvailableWindowId() async {
    // Use current timestamp in milliseconds for guaranteed uniqueness
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'window_$timestamp';
  }

  /// Registers a window as open
  static Future<void> registerWindow(String windowId) async {
    final prefs = await SharedPreferences.getInstance();
    final openWindows = prefs.getStringList(StorageKeys.openWindows) ?? [];

    if (!openWindows.contains(windowId)) {
      openWindows.add(windowId);
      await prefs.setStringList(StorageKeys.openWindows, openWindows);
    }
  }

  /// Unregisters a window when it's closed
  static Future<void> unregisterWindow(String windowId) async {
    final prefs = await SharedPreferences.getInstance();
    final openWindows = prefs.getStringList(StorageKeys.openWindows) ?? [];

    openWindows.remove(windowId);
    await prefs.setStringList(StorageKeys.openWindows, openWindows);
  }

  /// Gets the window title. Currently always returns the provided default name
  /// (no automatic numbering); caller may override with a custom string.
  static Future<String> getWindowTitle(String windowId, {String defaultName = 'tsubusu'}) async {
    // Keeping async signature for future flexibility and compatibility
    return defaultName;
  }
}
