import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../models/animation_type.dart';
import '../../services/preferences_service.dart';
import '../organisms/app_header.dart';
import '../organisms/todo_list.dart';
import '../molecules/settings_dialog.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Map<String, AnimationController> _animationControllers = {};
  AnimationType _animationType = AnimationType.confetti;

  @override
  void initState() {
    super.initState();
    _loadAnimationType();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
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
    
    setState(() {
      _todos.add(Todo(text: _controller.text.trim(), isCompleted: false));
    });
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      
      if (_todos[index].isCompleted) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 800),
          vsync: this,
        );
        _animationControllers[_todos[index].id] = controller;
        
        controller.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _animationControllers.remove(_todos[index].id);
                controller.dispose();
              });
            }
          });
        });
      }
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      final todoId = _todos[index].id;
      _animationControllers[todoId]?.dispose();
      _animationControllers.remove(todoId);
      _todos.removeAt(index);
    });
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
          TodoList(
            todos: _todos,
            animationControllers: _animationControllers,
            animationType: _animationType,
            onToggleTodo: _toggleTodo,
            onDeleteTodo: _deleteTodo,
          ),
        ],
      ),
    );
  }
}