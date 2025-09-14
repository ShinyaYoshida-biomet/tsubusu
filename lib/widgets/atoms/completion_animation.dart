import 'package:flutter/material.dart';

class CompletionAnimation extends StatelessWidget {
  final Animation<double> animation;
  final bool isSpecial;

  const CompletionAnimation({
    super.key,
    required this.animation,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = isSpecial ? 2.0 : 1.0;
    final int count = isSpecial ? 35 : 20;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(animation.value, scale: scale, count: count),
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final double scale;
  final int count;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  ConfettiPainter(this.progress, {required this.scale, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < count; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1 - progress)
        ..style = PaintingStyle.fill;

      final x = centerX + (i - count/2) * 15 * progress * scale;
      final y = centerY - 100 * progress * scale + 200 * progress * progress * scale;
      final radius = (3 + i % 3) * scale;

      canvas.drawCircle(Offset(x, y), radius * (1 - progress * 0.5), paint);
    }

    if (progress < 0.6) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '🎉',
          style: TextStyle(
            fontSize: 30 * (1 - progress) * scale,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          centerY - textPainter.height / 2 - 30 * progress * scale,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}