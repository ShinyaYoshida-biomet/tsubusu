import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../models/animation_type.dart';
import '../../services/preferences_service.dart';
import '../../services/shared_todo_service.dart';
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
  late SharedTodoService _todoService;

  @override
  void initState() {
    super.initState();
    _todoService = SharedTodoService.instance;
    _loadAnimationType();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadAnimationType() async {
    final animationType = await PreferencesService.getAnimationType();
    setState(() {
      _animationType = animationType;
    });
  }

  void _addTodo() {
    if (_controller.text.trim().isEmpty) return;
    
    _todoService.addTodo(_controller.text.trim());
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _toggleTodo(int index) {
    _todoService.toggleTodo(index);
  }

  void _deleteTodo(int index) {
    _todoService.deleteTodo(index);
  }

  void _reorderTodo(int oldIndex, int newIndex) {
    _todoService.reorderTodo(oldIndex, newIndex);
  }

  void _toggleTodoFromIndex(int index) {
    _todoService.toggleTodo(index);
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          AppHeader(
            controller: _controller,
            focusNode: _focusNode,
            onAddTodo: _addTodo,
            onShowSettings: _showSettings,
          ),
          ListenableBuilder(
            listenable: _todoService,
            builder: (context, child) {
              return TodoList(
                todos: _todoService.todos,
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