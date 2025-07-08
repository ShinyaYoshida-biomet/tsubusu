
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/services/window_manager.dart';

void main() {
  group('WindowManager', () {
    const channel = MethodChannel('tsubusu/window_manager');
    MethodCall? receivedCall;

    testWidgets('updateWindowTitle should invoke the correct method on the channel', (WidgetTester tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        receivedCall = methodCall;
        return null;
      });

      // Arrange
      const testTitle = 'My Test Title';

      // Act
      await WindowManager.updateWindowTitle(testTitle);

      // Assert
      expect(receivedCall, isNotNull);
      expect(receivedCall!.method, 'updateWindowTitle');
      expect(receivedCall!.arguments, {'title': testTitle});
    });
  });
}
