import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsubusu/services/window_registry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WindowRegistryService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('registers and unregisters persistent open list IDs', () async {
      await WindowRegistryService.registerOpenList('list_a');
      await WindowRegistryService.registerOpenList('list_b');
      await WindowRegistryService.registerOpenList('list_a');

      expect(await WindowRegistryService.getOpenListIds(), [
        'list_a',
        'list_b',
      ]);

      await WindowRegistryService.unregisterOpenList('list_a');

      expect(await WindowRegistryService.getOpenListIds(), ['list_b']);
    });
  });
}
