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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              padding: const EdgeInsets.all(8),
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
          painter: BubblePopPainter(animation.value),
        );
      },
    );
  }
}

class BubblePopPainter extends CustomPainter {
  final double progress;

  BubblePopPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    // Draw popping bubbles
    final bubbleCount = 8;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < bubbleCount; i++) {
      final angle = (i / bubbleCount) * 2 * 3.14159;
      
      // Bubble expands and fades
      final bubbleProgress = progress;
      final distance = 30 * bubbleProgress + 10;
      final x = centerX + distance * (angle.toString().hashCode % 2 == 0 ? 1 : -1) * (i % 2 == 0 ? 1 : 0.7);
      final y = centerY + distance * (angle.toString().hashCode % 2 == 0 ? 0.7 : 1) * (i % 2 == 0 ? -1 : 1);
      
      // Draw bubble with gradient
      final bubblePaint = Paint()
        ..color = Colors.teal.withOpacity(0.3 * (1 - progress))
        ..style = PaintingStyle.fill;
      
      final bubbleRadius = 15 * (1 + progress * 0.5);
      canvas.drawCircle(Offset(x, y), bubbleRadius, bubblePaint);
      
      // Draw bubble highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.4 * (1 - progress))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x - bubbleRadius * 0.3, y - bubbleRadius * 0.3),
        bubbleRadius * 0.3,
        highlightPaint,
      );
    }
    
    // Draw central pop effect
    if (progress < 0.3) {
      final popProgress = progress / 0.3;
      final popPaint = Paint()
        ..color = Colors.teal.withOpacity(0.2 * (1 - popProgress))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(centerX, centerY),
        40 * popProgress,
        popPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
