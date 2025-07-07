import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TsubusuApp());
}

class TsubusuApp extends StatelessWidget {
  const TsubusuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tsubusu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TodoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Todo {
  String text;
  bool isCompleted;
  final String id;

  Todo({required this.text, required this.isCompleted})
      : id = DateTime.now().millisecondsSinceEpoch.toString();
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final List<Todo> _todos = [];
  final TextEditingController _controller = TextEditingController();
  final Map<String, AnimationController> _animationControllers = {};

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTodo() {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _todos.add(Todo(text: _controller.text.trim(), isCompleted: false));
    });
    _controller.clear();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      
      if (_todos[index].isCompleted) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 1500),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tsubusu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a new task...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addTodo(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addTodo,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                final hasAnimation = _animationControllers.containsKey(todo.id);
                
                return Stack(
                  children: [
                    TodoItem(
                      todo: todo,
                      onToggle: () => _toggleTodo(index),
                      onDelete: () => _deleteTodo(index),
                    ),
                    if (hasAnimation)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CompletionAnimation(
                            animation: _animationControllers[todo.id]!,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          todo.text,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class CompletionAnimation extends StatelessWidget {
  final Animation<double> animation;

  const CompletionAnimation({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(animation.value),
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final random = List.generate(20, (i) => i);
    
    for (int i = 0; i < random.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      final x = size.width / 2 + (i - 10) * 20 * progress;
      final y = size.height / 2 - 200 * progress + 400 * progress * progress;
      final radius = 5 + i % 3;

      canvas.drawCircle(Offset(x, y), radius * (1 - progress * 0.5), paint);
    }

    if (progress < 0.5) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '🎉',
          style: TextStyle(
            fontSize: 40 * (1 - progress),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2 - 50 * progress,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
