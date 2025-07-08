import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/animation_type.dart';
import '../../services/preferences_service.dart';
import '../../services/window_todo_service.dart';
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
  AnimationType _animationType = AnimationType.confetti;
  WindowTodoService? _todoService;
  String _windowTitle = 'Tsubusu';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWindow();
    _loadAnimationType();
  }
  
  Future<void> _initializeWindow() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCounter = prefs.getInt('window_counter') ?? 0;
    final windowNumber = currentCounter + 1;
    await prefs.setInt('window_counter', windowNumber);
    final windowId = 'window_$windowNumber';
    
    _todoService = WindowTodoService(windowId);
    
    // Set unique window title
    _windowTitle = windowNumber == 1 ? 'tsubusu' : 'tsubusu $windowNumber';
    
    // Update the actual window title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WindowManager.updateWindowTitle(_windowTitle);
    });
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _todoService?.dispose();
    super.dispose();
  }

  void _loadAnimationType() async {
    final animationType = await PreferencesService.getAnimationType();
    setState(() {
      _animationType = animationType;
    });
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
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        currentAnimationType: _animationType,
        onAnimationTypeChanged: (type) {
          setState(() {
            _animationType = type;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
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
    );
  }
}