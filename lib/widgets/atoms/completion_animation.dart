import 'package:flutter/material.dart';
import '../../models/animation_type.dart';

class CompletionAnimation extends StatelessWidget {
  final Animation<double> animation;
  final AnimationType animationType;
  final bool isSpecial;

  const CompletionAnimation({
    super.key,
    required this.animation,
    required this.animationType,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: animationType == AnimationType.confetti
              ? ConfettiPainter(animation.value, isSpecial: isSpecial)
              : BubblePopPainter(animation.value, isSpecial: isSpecial),
        );
      },
    );
  }
}

class BubblePopPainter extends CustomPainter {
  final double progress;
  final bool isSpecial;

  BubblePopPainter(this.progress, {this.isSpecial = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final scale = isSpecial ? 2.0 : 1.0; // Make animation 2x bigger when special
    final bubbleCount = isSpecial ? 12 : 8; // More bubbles for special animation
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < bubbleCount; i++) {
      final angle = (i / bubbleCount) * 2 * 3.14159;
      
      final bubbleProgress = progress;
      final distance = (60 * bubbleProgress + 15) * scale;
      final x = centerX + distance * (angle.toString().hashCode % 2 == 0 ? 1 : -1) * (i % 2 == 0 ? 1 : 0.7);
      final y = centerY + distance * (angle.toString().hashCode % 2 == 0 ? 0.7 : 1) * (i % 2 == 0 ? -1 : 1);
      
      final bubblePaint = Paint()
        ..color = Colors.teal.withValues(alpha: 0.3 * (1 - progress))
        ..style = PaintingStyle.fill;
      
      final bubbleRadius = 15 * (1 + progress * 0.5) * scale;
      canvas.drawCircle(Offset(x, y), bubbleRadius, bubblePaint);
      
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4 * (1 - progress))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x - bubbleRadius * 0.3, y - bubbleRadius * 0.3),
        bubbleRadius * 0.3,
        highlightPaint,
      );
    }
    
    if (progress < 0.3) {
      final popProgress = progress / 0.3;
      final popPaint = Paint()
        ..color = Colors.teal.withValues(alpha: 0.2 * (1 - popProgress))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(centerX, centerY),
        40 * popProgress * scale,
        popPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final bool isSpecial;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  ConfettiPainter(this.progress, {this.isSpecial = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final scale = isSpecial ? 2.0 : 1.0; // Make animation 2x bigger when special
    final confettiCount = isSpecial ? 35 : 20; // More confetti for special animation
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < confettiCount; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1 - progress)
        ..style = PaintingStyle.fill;

      final x = centerX + (i - confettiCount/2) * 15 * progress * scale;
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