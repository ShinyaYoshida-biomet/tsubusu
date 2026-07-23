import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsubusu/models/todo.dart';
import 'package:tsubusu/providers/theme_provider.dart';
import 'package:tsubusu/widgets/organisms/todo_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the count of uncompleted top-level tasks', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TodoList(
                  todos: [
                    Todo(id: 'open-1', text: 'Open one', isCompleted: false),
                    Todo(id: 'open-2', text: 'Open two', isCompleted: false),
                    Todo(id: 'completed', text: 'Completed', isCompleted: true),
                    Todo(
                      id: 'child',
                      text: 'Completed child',
                      isCompleted: true,
                      parentId: 'open-1',
                    ),
                  ],
                  onToggleTodo: (_) {},
                  onDeleteTodo: (_) {},
                  onAddSubtask: (_, __) {},
                  onEditTodo: (_, __) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Uncompleted (2)'), findsOneWidget);
    expect(find.text('Completed (1)'), findsOneWidget);
  });

  testWidgets('animates and toggles when the card body is tapped', (
    tester,
  ) async {
    String? toggledTodoId;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TodoList(
                  todos: [
                    Todo(id: 'open-1', text: 'Open one', isCompleted: false),
                  ],
                  onToggleTodo: (id) => toggledTodoId = id,
                  onDeleteTodo: (_) {},
                  onAddSubtask: (_, __) {},
                  onEditTodo: (_, __) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ListTile).first);
    await tester.pump(const Duration(milliseconds: 400));

    // The card body should use the same delayed animation path as the checkbox,
    // rather than toggling immediately on tap.
    expect(toggledTodoId, isNull);
  });
}
