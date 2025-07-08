import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WindowManager {
  static const String _windowTitle = 'Tsubusu';
  static const Size _defaultWindowSize = Size(300, 400);
  static const Size _minWindowSize = Size(250, 300);
  static const Size _maxWindowSize = Size(600, 800);

  static Future<void> updateWindowTitle(String title) async {
    try {
      const MethodChannel('tsubusu/window_manager').invokeMethod('updateWindowTitle', {'title': title});
    } catch (e) {
      print('Failed to update window title: $e');
    }
  }

  /// Creates a new window with the todo app
  static Future<WindowController?> createNewWindow({Offset? position}) async {
    try {
      final window = await DesktopMultiWindow.createWindow(jsonEncode({
        'type': 'todo_window',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));

      final newPosition = position ?? const Offset(100, 100);

      await window.setFrame(newPosition & _defaultWindowSize);
      await window.setTitle(_windowTitle);
      await window.show();

      return window;
    } catch (e) {
      debugPrint('Failed to create new window: $e');
      return null;
    }
  }

  /// Gets the current window controller
  static WindowController getCurrentWindow() {
    return WindowController.fromWindowId(0);
  }

  /// Shows a window creation menu at the specified position
  static void showWindowMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: 'new_window',
          child: Row(
            children: const [
              Icon(Icons.add, size: 16),
              SizedBox(width: 8),
              Text('New Window'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'new_window_here',
          child: Row(
            children: const [
              Icon(Icons.open_in_new, size: 16),
              SizedBox(width: 8),
              Text('New Window Here'),
            ],
          ),
        ),
      ],
    ).then((value) {
      switch (value) {
        case 'new_window':
          createNewWindow(position: const Offset(130, 130));
          break;
        case 'new_window_here':
          createNewWindow();
          break;
      }
    });
  }
}