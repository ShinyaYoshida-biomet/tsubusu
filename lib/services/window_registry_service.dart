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

  /// Gets the window title based on the position in the currently open windows list
  /// This ensures window titles are always sequential (tsubusu, tsubusu 2, tsubusu 3)
  /// regardless of the internal window IDs
  static Future<String> getWindowTitle(String windowId, {String defaultName = 'tsubusu'}) async {
    final prefs = await SharedPreferences.getInstance();
    final openWindows = prefs.getStringList(StorageKeys.openWindows) ?? [];

    // Find the position of this window in the open windows list
    final position = openWindows.indexOf(windowId) + 1;

    if (position <= 1) {
      return defaultName;
    }

    return '$defaultName $position';
  }
}