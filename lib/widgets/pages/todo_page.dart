import 'package:flutter/material.dart';
import '../../models/todo_list_id.dart';
import '../../services/window_registry_service.dart';
import '../../services/todo_list_service.dart';
import '../../services/window_manager.dart';
import '../organisms/app_header.dart';
import '../organisms/todo_list.dart';
import '../molecules/settings_dialog.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  TodoListService? _todoService;
  String? _windowId;
  String _windowTitle = 'Tsubusu';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWindow();
  }

  Future<void> _initializeWindow() async {
    if (WindowManager.supportsWindowManagement) {
      final windowId = await WindowRegistryService.getNextAvailableWindowId();
      _windowId = windowId;
      await WindowRegistryService.registerWindow(windowId);
    }

    // A desktop window presents a logical list; it does not own the list's
    // identity or persistence. Mobile can create and present TodoListIds too.
    final todoService = TodoListService(TodoListId.create());
    _todoService = todoService;
    await todoService.ready;

    if (!mounted) {
      await _removeFromOpenWindows();
      return;
    }

    if (_windowId != null) {
      // Window registration and native title changes are desktop-only.
      _windowTitle = await WindowRegistryService.getWindowTitle(_windowId!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WindowManager.updateWindowTitle(_windowTitle);
      });
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _removeFromOpenWindows();
    _controller.dispose();
    _focusNode.dispose();
    _todoService?.dispose();
    super.dispose();
  }

  Future<void> _removeFromOpenWindows() async {
    if (_windowId != null) {
      await WindowRegistryService.unregisterWindow(_windowId!);
    }
  }

  void _addTodo() {
    if (_controller.text.trim().isEmpty || _todoService == null) return;

    _todoService!.addTodo(_controller.text.trim());
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _deleteTodo(int index) {
    _todoService?.deleteTodo(index);
  }

  void _reorderTodo(int oldIndex, int newIndex) {
    _todoService?.reorderTodo(oldIndex, newIndex);
  }

  void _toggleTodoFromIndex(int index) {
    _todoService?.toggleTodo(index);
  }

  void _onTitleChanged(String newTitle) {
    setState(() {
      _windowTitle = newTitle;
    });
    // Update the actual window title
    WindowManager.updateWindowTitle(newTitle);
  }

  void _showSettings() {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              controller: _controller,
              focusNode: _focusNode,
              onAddTodo: _addTodo,
              onShowSettings: _showSettings,
              windowTitle: _windowTitle,
              onTitleChanged: _onTitleChanged,
            ),
            ListenableBuilder(
              listenable: _todoService!,
              builder: (context, child) {
                return TodoList(
                  todos: _todoService!.todos,
                  onToggleTodo: _toggleTodoFromIndex,
                  onDeleteTodo: _deleteTodo,
                  onReorderTodo: _reorderTodo,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
