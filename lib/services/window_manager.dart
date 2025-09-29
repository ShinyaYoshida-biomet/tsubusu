import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_constants.dart';

class WindowManager {
  static const String _windowTitle = 'Tsubusu';
  static const Size _defaultWindowSize = Size(300, 400);
  static const Offset _defaultWindowPosition = Offset(100, 100);
  static const Offset _offsetWindowPosition = Offset(130, 130);

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

      final newPosition = position ?? _defaultWindowPosition;

      await window.setFrame(newPosition & _defaultWindowSize);
      await window.setTitle(_windowTitle);
      await window.show();

      return window;
    } catch (e) {
      debugPrint('Failed to create new window: $e');
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
            children: [
              Icon(Icons.add, size: DesignConstants.iconSizeSmall),
              SizedBox(width: DesignConstants.spacingSmall),
              const Text('New Window'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'new_window_here',
          child: Row(
            children: [
              Icon(Icons.open_in_new, size: DesignConstants.iconSizeSmall),
              SizedBox(width: DesignConstants.spacingSmall),
              const Text('New Window Here'),
            ],
          ),
        ),
      ],
    ).then((value) {
      switch (value) {
        case 'new_window':
          createNewWindow(position: _offsetWindowPosition);
          break;
        case 'new_window_here':
          createNewWindow();
          break;
      }
    });
  }
}