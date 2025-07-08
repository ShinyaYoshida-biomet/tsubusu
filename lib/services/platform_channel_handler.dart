import 'package:flutter/services.dart';
import 'window_manager.dart';

class PlatformChannelHandler {
  static const MethodChannel _channel = MethodChannel('tsubusu/window_manager');
  
  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'createNewWindow':
        await WindowManager.createNewWindow(position: const Offset(130, 130));
        return null;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }
  
  static Future<void> updateWindowTitle(String title) async {
    try {
      await _channel.invokeMethod('updateWindowTitle', {'title': title});
    } catch (e) {
      print('Failed to update window title: $e');
    }
  }
}