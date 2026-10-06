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

  testWidgets('does not toggle when the card body is tapped', (tester) async {
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

    expect(toggledTodoId, isNull);
  });

  testWidgets('displays subtask counter badge on parent task', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TodoList(
                  todos: [
                    Todo(id: 'parent', text: 'Parent task', isCompleted: false),
                    Todo(
                      id: 'sub-1',
                      text: 'Done sub',
                      isCompleted: true,
                      parentId: 'parent',
                    ),
                    Todo(
                      id: 'sub-2',
                      text: 'Open sub',
                      isCompleted: false,
                      parentId: 'parent',
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

    // Parent task should display subtask counter badge '1/2'
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('shows native-styled subtask input and submits subtask', (tester) async {
    String? addedParentId;
    String? addedText;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TodoList(
                  todos: [
                    Todo(id: 'parent', text: 'Parent task', isCompleted: false),
                  ],
                  onToggleTodo: (_) {},
                  onDeleteTodo: (_) {},
                  onAddSubtask: (pId, text) {
                    addedParentId = pId;
                    addedText = text;
                  },
                  onEditTodo: (_, __) {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Right-click or long-press to open menu
    await tester.tap(find.byType(ListTile).first, buttons: 2); // secondary tap
    await tester.pumpAndSettle();

    // Tap "サブタスクを追加"
    expect(find.text('サブタスクを追加'), findsOneWidget);
    await tester.tap(find.text('サブタスクを追加'));
    await tester.pumpAndSettle();

    // Subtask input field should be visible with borderless style and placeholder
    expect(find.text('サブタスクを追加…'), findsOneWidget);

    // Enter subtask title
    await tester.enterText(find.byType(TextField).last, 'My new subtask');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(addedParentId, 'parent');
    expect(addedText, 'My new subtask');
    // Input should be dismissed
    expect(find.text('サブタスクを追加…'), findsNothing);
  });
}
