
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/services/window_manager.dart';

void main() {
  group('WindowManager', () {
    const channel = MethodChannel('tsubusu/window_manager');
    MethodCall? receivedCall;

    testWidgets('updateWindowTitle should invoke the correct method on the channel', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
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
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('only enables native window management on desktop platforms', () {
      expect(WindowManager.isDesktopPlatform(TargetPlatform.macOS), isTrue);
      expect(WindowManager.isDesktopPlatform(TargetPlatform.windows), isTrue);
      expect(WindowManager.isDesktopPlatform(TargetPlatform.android), isFalse);
      expect(WindowManager.isDesktopPlatform(TargetPlatform.iOS), isFalse);
    });
  });
}
