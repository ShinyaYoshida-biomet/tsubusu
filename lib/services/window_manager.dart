import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WindowManager {
  static bool get supportsWindowManagement =>
      isDesktopPlatform(defaultTargetPlatform);

  @visibleForTesting
  static bool isDesktopPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows;
  }

  static Future<void> updateWindowTitle(String title) async {
    if (!supportsWindowManagement) {
      return;
    }

    try {
      const MethodChannel(
        'tsubusu/window_manager',
      ).invokeMethod('updateWindowTitle', {'title': title});
    } catch (e) {
      debugPrint('Failed to update window title: $e');
    }
  }
}
