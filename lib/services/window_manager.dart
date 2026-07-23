import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';

class WindowManager {
  static const _channel = MethodChannel('tsubusu/window_manager');
  static Future<void> Function()? _newWindowHandler;

  static bool get supportsWindowManagement =>
      isDesktopPlatform(defaultTargetPlatform);

  @visibleForTesting
  static bool isDesktopPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows;
  }

  static void registerMainWindowHandlers({
    required Future<void> Function() onNewWindow,
  }) {
    _newWindowHandler = onNewWindow;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'newWindow') {
        await _newWindowHandler?.call();
      }
    });
  }

  static Future<WindowController> createWindow({
    required String listId,
    required String title,
  }) async {
    final controller = await DesktopMultiWindow.createWindow(
      jsonEncode({'listId': listId}),
    );
    await controller.setFrameAutosaveName('tsubusu_$listId');
    await controller.setTitle(title);
    await controller.show();
    return controller;
  }

  static Future<void> updateWindowTitle(String title) async {
    if (!supportsWindowManagement) {
      return;
    }

    try {
      await _channel.invokeMethod('updateWindowTitle', {'title': title});
    } catch (e) {
      debugPrint('Failed to update window title: $e');
    }
  }
}
