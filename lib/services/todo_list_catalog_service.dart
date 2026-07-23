import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../models/todo_list_id.dart';
import '../models/todo_list_record.dart';

class TodoListCatalogService {
  static const defaultTitle = 'tsubusu';

  Future<List<TodoListRecord>> loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final encoded = prefs.getString(StorageKeys.todoListCatalog);
    if (encoded != null) {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .map((item) => TodoListRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final migrated = _discoverPersistedLists(prefs);
    if (migrated.isNotEmpty) {
      await _saveLists(prefs, migrated);
    }
    return migrated;
  }

  Future<TodoListRecord> ensureDefaultList() async {
    final lists = await loadLists();
    if (lists.isNotEmpty) return lists.first;
    return createList();
  }

  Future<TodoListRecord> createList({String title = defaultTitle}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lists = await _loadListsFromPreferences(prefs);
    final record = TodoListRecord(
      id: TodoListId.create(),
      title: title.trim().isEmpty ? defaultTitle : title.trim(),
    );
    lists.add(record);
    await _saveLists(prefs, lists);
    return record;
  }

  Future<void> updateTitle(TodoListId id, String title) async {
    final normalized = title.trim();
    if (normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lists = await _loadListsFromPreferences(prefs);
    final index = lists.indexWhere((list) => list.id == id);
    if (index == -1) return;
    lists[index] = lists[index].copyWith(title: normalized);
    await _saveLists(prefs, lists);
  }

  Future<void> deleteList(TodoListId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lists = await _loadListsFromPreferences(prefs);
    lists.removeWhere((list) => list.id == id);
    await _saveLists(prefs, lists);

    await prefs.remove(StorageKeys.todosForList(id));
    final openListIds = prefs.getStringList(StorageKeys.openListIds) ?? [];
    openListIds.remove(id.value);
    await prefs.setStringList(StorageKeys.openListIds, openListIds);
  }

  Future<List<TodoListRecord>> _loadListsFromPreferences(
    SharedPreferences prefs,
  ) async {
    final encoded = prefs.getString(StorageKeys.todoListCatalog);
    if (encoded == null) return _discoverPersistedLists(prefs);
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map((item) => TodoListRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<TodoListRecord> _discoverPersistedLists(SharedPreferences prefs) {
    final ids =
        prefs
            .getKeys()
            .where((key) => key.startsWith('todos_list_'))
            .map((key) => key.substring('todos_list_'.length))
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return [
      for (var i = 0; i < ids.length; i++)
        TodoListRecord(
          id: TodoListId.fromValue(ids[i]),
          title: i == 0 ? defaultTitle : '$defaultTitle ${i + 1}',
        ),
    ];
  }

  Future<void> _saveLists(
    SharedPreferences prefs,
    List<TodoListRecord> lists,
  ) async {
    await prefs.setString(
      StorageKeys.todoListCatalog,
      jsonEncode(lists.map((list) => list.toJson()).toList()),
    );
  }
}
