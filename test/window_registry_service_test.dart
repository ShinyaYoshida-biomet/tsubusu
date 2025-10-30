import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsubusu/services/window_registry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WindowRegistryService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    group('getNextAvailableWindowId', () {
      test('should return window_1 for first window', () async {
        final windowId = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId, 'window_1');
      });

      test('should return window_2 for second window', () async {
        await WindowRegistryService.getNextAvailableWindowId(); // window_1
        final windowId = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId, 'window_2');
      });

      test('should return window_3 for third window', () async {
        await WindowRegistryService.getNextAvailableWindowId(); // window_1
        await WindowRegistryService.getNextAvailableWindowId(); // window_2
        final windowId = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId, 'window_3');
      });

      test('should not reuse window IDs when windows are closed', () async {
        // Create and register window_1
        final windowId1 = await WindowRegistryService.getNextAvailableWindowId();
        await WindowRegistryService.registerWindow(windowId1);
        expect(windowId1, 'window_1');

        // Close window_1
        await WindowRegistryService.unregisterWindow(windowId1);

        // Next window should be window_2, not reusing window_1
        final windowId2 = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId2, 'window_2');
      });

      test('should increment counter independently of open windows list', () async {
        // Set counter to 5
        SharedPreferences.setMockInitialValues({'next_window_counter': 5});

        final windowId = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId, 'window_5');

        // Next should be window_6
        final windowId2 = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId2, 'window_6');
      });
    });

    group('registerWindow', () {
      test('should add window to open windows list', () async {
        await WindowRegistryService.registerWindow('window_1');

        final prefs = await SharedPreferences.getInstance();
        final openWindows = prefs.getStringList('open_windows');

        expect(openWindows, contains('window_1'));
      });

      test('should not add duplicate windows', () async {
        await WindowRegistryService.registerWindow('window_1');
        await WindowRegistryService.registerWindow('window_1');

        final prefs = await SharedPreferences.getInstance();
        final openWindows = prefs.getStringList('open_windows');

        expect(openWindows?.where((w) => w == 'window_1').length, 1);
      });

      test('should handle multiple windows', () async {
        await WindowRegistryService.registerWindow('window_1');
        await WindowRegistryService.registerWindow('window_2');
        await WindowRegistryService.registerWindow('window_3');

        final prefs = await SharedPreferences.getInstance();
        final openWindows = prefs.getStringList('open_windows');

        expect(openWindows, ['window_1', 'window_2', 'window_3']);
      });
    });

    group('unregisterWindow', () {
      test('should remove window from open windows list', () async {
        SharedPreferences.setMockInitialValues({'open_windows': ['window_1', 'window_2']});

        await WindowRegistryService.unregisterWindow('window_1');

        final prefs = await SharedPreferences.getInstance();
        final openWindows = prefs.getStringList('open_windows');

        expect(openWindows, ['window_2']);
        expect(openWindows, isNot(contains('window_1')));
      });

      test('should handle unregistering non-existent window', () async {
        SharedPreferences.setMockInitialValues({'open_windows': ['window_1']});

        await WindowRegistryService.unregisterWindow('window_99');

        final prefs = await SharedPreferences.getInstance();
        final openWindows = prefs.getStringList('open_windows');

        expect(openWindows, ['window_1']);
      });

      test('should handle empty list', () async {
        await WindowRegistryService.unregisterWindow('window_1');

        final prefs = await SharedPreferences.getInstance();
        final openWindows = prefs.getStringList('open_windows');

        expect(openWindows, []);
      });
    });

    group('getWindowTitle', () {
      test('should return default name for window_1', () {
        final title = WindowRegistryService.getWindowTitle('window_1');
        expect(title, 'tsubusu');
      });

      test('should return numbered title for window_2', () {
        final title = WindowRegistryService.getWindowTitle('window_2');
        expect(title, 'tsubusu 2');
      });

      test('should return numbered title for window_10', () {
        final title = WindowRegistryService.getWindowTitle('window_10');
        expect(title, 'tsubusu 10');
      });

      test('should handle custom default name', () {
        final title = WindowRegistryService.getWindowTitle('window_1', defaultName: 'MyApp');
        expect(title, 'MyApp');
      });

      test('should handle custom default name with number', () {
        final title = WindowRegistryService.getWindowTitle('window_3', defaultName: 'MyApp');
        expect(title, 'MyApp 3');
      });

      test('should handle invalid window id format', () {
        final title = WindowRegistryService.getWindowTitle('invalid_id');
        expect(title, 'tsubusu');
      });
    });
  });
}