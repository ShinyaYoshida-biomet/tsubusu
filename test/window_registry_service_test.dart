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
      test('should return window ID with timestamp format', () async {
        final windowId = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId, startsWith('window_'));

        // Extract timestamp and verify it's a valid number
        final timestamp = windowId.replaceFirst('window_', '');
        expect(int.tryParse(timestamp), isNotNull);
      });

      test('should return unique window IDs', () async {
        final windowId1 = await WindowRegistryService.getNextAvailableWindowId();
        await Future.delayed(const Duration(milliseconds: 1)); // Ensure different timestamps
        final windowId2 = await WindowRegistryService.getNextAvailableWindowId();

        expect(windowId1, isNot(equals(windowId2)));
      });

      test('should never reuse window IDs (timestamp-based)', () async {
        // Create and register window
        final windowId1 = await WindowRegistryService.getNextAvailableWindowId();
        await WindowRegistryService.registerWindow(windowId1);

        // Close window
        await WindowRegistryService.unregisterWindow(windowId1);

        // Next window should have different ID (different timestamp)
        await Future.delayed(const Duration(milliseconds: 1));
        final windowId2 = await WindowRegistryService.getNextAvailableWindowId();
        expect(windowId1, isNot(equals(windowId2)));
      });

      test('should create window IDs with increasing timestamps', () async {
        final windowId1 = await WindowRegistryService.getNextAvailableWindowId();
        final timestamp1 = int.parse(windowId1.replaceFirst('window_', ''));

        await Future.delayed(const Duration(milliseconds: 2));

        final windowId2 = await WindowRegistryService.getNextAvailableWindowId();
        final timestamp2 = int.parse(windowId2.replaceFirst('window_', ''));

        expect(timestamp2, greaterThan(timestamp1));
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
      test('should return default name regardless of position', () async {
        SharedPreferences.setMockInitialValues({'open_windows': ['window_1', 'window_2']});
        final title = await WindowRegistryService.getWindowTitle('window_2');
        expect(title, 'tsubusu');
      });

      test('should handle custom default name without numbering', () async {
        SharedPreferences.setMockInitialValues({'open_windows': ['window_1', 'window_2', 'window_3']});
        final title = await WindowRegistryService.getWindowTitle('window_3', defaultName: 'MyApp');
        expect(title, 'MyApp');
      });

      test('should return default when window not in list', () async {
        SharedPreferences.setMockInitialValues({'open_windows': ['window_1']});
        final title = await WindowRegistryService.getWindowTitle('window_99');
        expect(title, 'tsubusu');
      });
    });
  });
}
