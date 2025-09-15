import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  final bool isStatic;
  const AnimatedCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.isStatic = false,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with TickerProviderStateMixin {
  late AnimationController _squeezeController;
  late AnimationController _popController;
  late Animation<double> _squeezeAnimation;
  late Animation<double> _popScaleAnimation;
  late Animation<double> _popOpacityAnimation;
  bool _isAnimating = false; // Track animation state

  @override
  void initState() {
    super.initState();
    
    // Squeeze animation controller for simple crush effect
    _squeezeController = AnimationController(
      duration: const Duration(milliseconds: 500), // Smooth crush duration
      vsync: this,
    );
    
    // Pop animation controller for star burst effect
    _popController = AnimationController(
      duration: const Duration(milliseconds: 300), // Star flight duration
      vsync: this,
    );
    
    // Simple height squeeze animation for "tsubusu" effect
    _squeezeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.05, // Crush down to 5% height
    ).animate(CurvedAnimation(
      parent: _squeezeController,
      curve: Curves.easeInCubic, // Accelerating crush feeling
    ));

    // Star burst distance animation - stars fly outward
    _popScaleAnimation = Tween<double>(
      begin: 0.0,  // Start from center
      end: 50.0,   // Fly out 50 pixels from center
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOutCubic, // Smooth deceleration as they fly out
    ));

    // Star opacity animation - fade out during flight
    _popOpacityAnimation = Tween<double>(
      begin: 1.0, // Fully visible
      end: 0.0,   // Fade to transparent
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOut, // Fade out quickly
    ));
  }

  @override
  void dispose() {
    _squeezeController.dispose();
    _popController.dispose();
    super.dispose();
  }

  void _animateCheck() async {
    // For static mode (completed items), just toggle immediately
    if (widget.isStatic) {
      widget.onChanged?.call(!widget.value);
      return;
    }
    
    // Prevent multiple simultaneous animations
    if (_isAnimating) return;
    
    if (!widget.value) {
      setState(() {
        _isAnimating = true;
      });
      
      try {
        // Execute simple crush followed by balloon pop effect
        await _squeezeController.forward(); // Simple crush animation
        await _executePopEffect(); // Balloon burst effect
        widget.onChanged?.call(true); // Trigger state change after animation completes
      } finally {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      }
    } else {
      // Immediate toggle for unchecking
      widget.onChanged?.call(false);
      _squeezeController.reset();
      _popController.reset();
    }
  }

  // Execute balloon pop effect after crush
  Future<void> _executePopEffect() async {
    // Brief pause before pop effect
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Quick outward burst effect to simulate balloon pop
    await _popController.forward();
    
    // Reset pop controller for next use
    _popController.reset();
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only reset animations when this specific checkbox value changes externally
    // and it's being unchecked (not when other checkboxes trigger rebuilds)
    if (oldWidget.value != widget.value && !widget.value && !_isAnimating) {
      _squeezeController.reset();
      _popController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animateCheck,
      child: AnimatedBuilder(
        animation: Listenable.merge([_squeezeController, _popController]),
        builder: (context, child) {
          double heightScale;
          double widthScale;
          double opacity = 1.0;
          Color? backgroundColor;
          
          if (widget.isStatic) {
            // Static mode for completed items - always normal size
            heightScale = 1.0;
            widthScale = 1.0;
            backgroundColor = widget.value 
                ? (widget.activeColor ?? Colors.teal)
                : Colors.grey[300];
          } else if (_squeezeController.isAnimating) {
            // Squeezing animation
            heightScale = _squeezeAnimation.value;
            widthScale = 1.0 + (1.0 - heightScale) * 0.2; // Slight width increase when squished
            backgroundColor = Colors.grey[300];
          } else if (widget.value) {
            // Keep the completed state styling in compressed form
            heightScale = 0.05; // Stay compressed
            widthScale = 1.0 + (1.0 - heightScale) * 0.2;
            backgroundColor = widget.activeColor ?? Colors.teal;
          } else {
            heightScale = 1.0;
            widthScale = 1.0;
            backgroundColor = Colors.grey[300];
          }
          
          return SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // Allow stars to overflow
              children: [
                // Main checkbox - hidden during star burst animation
                if (!_popController.isAnimating)
                  Opacity(
                    opacity: opacity,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(widthScale, heightScale), // Scale based on animation state
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: widget.value 
                              ? (widget.activeColor ?? Colors.teal)
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        boxShadow: [
                          if (_squeezeController.isAnimating || widget.value)
                            BoxShadow(
                              color: (widget.activeColor ?? Colors.teal).withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: widget.value
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                      ),
                    ),
                  ),
                // Star burst effect - positioned absolutely over checkbox
                if (_popController.isAnimating)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: StarBurstPainter(
                        progress: _popScaleAnimation.value,
                        opacity: _popOpacityAnimation.value,
                        color: widget.activeColor ?? Colors.teal,
                        starCount: 8,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for star burst effect
class StarBurstPainter extends CustomPainter {
  final double progress;
  final double opacity;
  final Color color;
  final int starCount;

  StarBurstPainter({
    required this.progress,
    required this.opacity,
    required this.color,
    this.starCount = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0 || opacity == 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Draw stars flying outward from center
    for (int i = 0; i < starCount; i++) {
      final angle = (i / starCount) * 2 * math.pi;
      final distance = progress;
      
      // Calculate star position
      final starX = center.dx + distance * math.cos(angle);
      final starY = center.dy + distance * math.sin(angle);
      final starCenter = Offset(starX, starY);
      
      // Draw rotating star
      final rotation = progress * 6; // Multiple rotations during flight
      _drawStar(canvas, paint, starCenter, 5.0, rotation);
    }
  }

  // Draw a 5-pointed star
  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius, double rotation) {
    final path = Path();
    const int points = 5;
    final double outerRadius = radius;
    final double innerRadius = radius * 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) + rotation;
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
