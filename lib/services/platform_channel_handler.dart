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
        await WindowManager.createOffsetWindow();
        return null;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'Method ${call.method} not implemented',
        );
    }
  }
}