import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WindowManager {
  static Future<void> updateWindowTitle(String title) async {
    try {
      const MethodChannel('tsubusu/window_manager').invokeMethod('updateWindowTitle', {'title': title});
    } catch (e) {
      debugPrint('Failed to update window title: $e');
    }
  }
}