import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

class WindowManager {
  static const String _windowTitle = 'Tsubusu';
  static const Size _defaultWindowSize = Size(300, 400);
  static const Size _minWindowSize = Size(250, 300);
  static const Size _maxWindowSize = Size(600, 800);

  /// Creates a new window with the todo app
  static Future<WindowController?> createNewWindow() async {
    try {
      final window = await DesktopMultiWindow.createWindow(jsonEncode({
        'type': 'todo_window',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      
      await window.setFrame(const Offset(100, 100) & _defaultWindowSize);
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

  /// Creates a new window positioned offset from the current one
  static Future<WindowController?> createOffsetWindow() async {
    try {
      // Create window with default offset
      final newPosition = Offset(
        130, // Offset from default position
        130,
      );

      final window = await DesktopMultiWindow.createWindow(jsonEncode({
        'type': 'todo_window',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      
      // Configure window like the main window
      await window.setFrame(newPosition & _defaultWindowSize);
      await window.setTitle(_windowTitle);
      await window.show();

      return window;
    } catch (e) {
      debugPrint('Failed to create offset window: $e');
      return null;
    }
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
          createOffsetWindow();
          break;
        case 'new_window_here':
          createNewWindow();
          break;
      }
    });
  }
}