import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsubusu/constants/storage_keys.dart';
import 'package:tsubusu/models/todo_list_id.dart';
import 'package:tsubusu/models/todo_list_record.dart';
import 'package:tsubusu/services/todo_list_catalog_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TodoListCatalogService', () {
    late TodoListCatalogService catalog;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      catalog = TodoListCatalogService();
    });

    test('persists the default list and reloads it', () async {
      final created = await catalog.ensureDefaultList();
      final reloaded = await TodoListCatalogService().loadLists();

      expect(reloaded, hasLength(1));
      expect(reloaded.single.id, created.id);
      expect(reloaded.single.title, 'tsubusu');
    });

    test('persists title updates', () async {
      final created = await catalog.createList(title: 'Work');

      await catalog.updateTitle(created.id, '  Personal  ');

      expect((await catalog.loadLists()).single.title, 'Personal');
    });

    test('discovers existing todo list keys from pre-catalog data', () async {
      const listId = 'list_existing';
      SharedPreferences.setMockInitialValues({'todos_list_$listId': '[]'});

      final lists = await catalog.loadLists();

      expect(lists.single.id, TodoListId.fromValue(listId));
      expect(
        (await SharedPreferences.getInstance()).getString(
          StorageKeys.todoListCatalog,
        ),
        isNotNull,
      );
    });

    test('uses the same default title for discovered lists', () async {
      SharedPreferences.setMockInitialValues({
        'todos_list_first': '[]',
        'todos_list_second': '[]',
      });

      final lists = await catalog.loadLists();

      expect(lists.map((list) => list.title), ['tsubusu', 'tsubusu']);
    });

    test(
      'normalizes legacy generated titles without changing custom titles',
      () async {
        final first = TodoListRecord(
          id: TodoListId.fromValue('first'),
          title: 'tsubusu 42',
        );
        final second = TodoListRecord(
          id: TodoListId.fromValue('second'),
          title: 'My project',
        );
        SharedPreferences.setMockInitialValues({
          StorageKeys.todoListCatalog: jsonEncode([
            first.toJson(),
            second.toJson(),
          ]),
        });

        final lists = await catalog.loadLists();

        expect(lists[0].title, 'tsubusu');
        expect(lists[1].title, 'My project');
      },
    );

    test('deletes a list, its tasks, and its open session entry', () async {
      final created = await catalog.createList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.todosForList(created.id), '[{}]');
      await prefs.setStringList(StorageKeys.openListIds, [created.id.value]);

      await catalog.deleteList(created.id);

      expect((await catalog.loadLists()), isEmpty);
      expect(prefs.getString(StorageKeys.todosForList(created.id)), isNull);
      expect(prefs.getStringList(StorageKeys.openListIds), isEmpty);
    });
  });
}
