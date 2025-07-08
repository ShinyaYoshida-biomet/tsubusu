import 'package:flutter/material.dart';
import '../../models/animation_type.dart';
import '../../services/preferences_service.dart';
import '../../services/window_todo_service.dart';
import '../../services/window_counter_service.dart';
import '../../services/platform_channel_handler.dart';
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
    // Get auto-incremented window number
    final windowNumber = await WindowCounterService.getNextWindowNumber();
    final windowId = 'window_$windowNumber';
    
    _todoService = WindowTodoService(windowId);
    
    // Set unique window title
    _windowTitle = windowNumber == 1 ? 'tsubusu' : 'tsubusu $windowNumber';
    
    // Update the actual window title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PlatformChannelHandler.updateWindowTitle(_windowTitle);
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
    PlatformChannelHandler.updateWindowTitle(newTitle);
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