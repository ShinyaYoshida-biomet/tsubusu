import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class WindowRegistryService {
  /// Finds the next available window ID by checking open windows
  static Future<String> getNextAvailableWindowId() async {
    final prefs = await SharedPreferences.getInstance();
    final openWindows = prefs.getStringList(StorageKeys.openWindows) ?? [];

    // Find the lowest available window number
    int windowNumber = 1;
    while (openWindows.contains('window_$windowNumber')) {
      windowNumber++;
    }

    return 'window_$windowNumber';
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

  /// Gets the window title for a given window ID
  static String getWindowTitle(String windowId, {String defaultName = 'tsubusu'}) {
    // Extract window number from windowId (e.g., "window_1" -> 1)
    final windowNumber = int.tryParse(windowId.replaceFirst('window_', ''));

    if (windowNumber == null || windowNumber == 1) {
      return defaultName;
    }

    return '$defaultName $windowNumber';
  }
}