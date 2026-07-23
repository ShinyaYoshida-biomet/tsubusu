import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class WindowRegistryService {
  static Future<List<String>> getOpenListIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getStringList(StorageKeys.openListIds) ?? [];
  }

  static Future<void> registerOpenList(String listId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final openListIds = prefs.getStringList(StorageKeys.openListIds) ?? [];
    if (!openListIds.contains(listId)) {
      openListIds.add(listId);
      await prefs.setStringList(StorageKeys.openListIds, openListIds);
    }
  }

  static Future<void> unregisterOpenList(String listId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final openListIds = prefs.getStringList(StorageKeys.openListIds) ?? [];
    if (openListIds.remove(listId)) {
      await prefs.setStringList(StorageKeys.openListIds, openListIds);
    }
  }
}
