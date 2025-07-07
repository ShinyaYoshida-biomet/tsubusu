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
    final wasCompleted = _todos[index].isCompleted;
    
    if (!wasCompleted) {
      // Task is being completed - play animation first, then move
      final todoId = _todos[index].id;
      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      
      setState(() {
        _animationControllers[todoId] = controller;
      });
      
      controller.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              // Now actually mark as completed and move to bottom section
              _todos[index].isCompleted = true;
              _animationControllers.remove(todoId);
              controller.dispose();
            });
          }
        });
      });
    } else {
      // Task is being uncompleted - just toggle immediately
      setState(() {
        _todos[index].isCompleted = false;
      });
    }
  }


  void _deleteTodo(int index) {
    setState(() {
      if (index >= 0 && index < _todos.length) {
        final todoId = _todos[index].id;
        _animationControllers[todoId]?.dispose();
        _animationControllers.remove(todoId);
        _todos.removeAt(index);
      }
    });
  }

  void _reorderTodo(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex >= 0 && oldIndex < _todos.length && 
          newIndex >= 0 && newIndex < _todos.length) {
        final todo = _todos.removeAt(oldIndex);
        _todos.insert(newIndex, todo);
      }
    });
  }

  void _toggleTodoFromIndex(int index) {
    if (index >= 0 && index < _todos.length) {
      _toggleTodo(index);
    }
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
            originalTodos: _todos,
            animationControllers: _animationControllers,
            animationType: _animationType,
            onToggleTodo: _toggleTodoFromIndex,
            onDeleteTodo: _deleteTodo,
            onReorderTodo: _reorderTodo,
            allCompleted: _todos.isNotEmpty && _todos.every((todo) => todo.isCompleted),
          ),
        ],
      ),
    );
  }
}