import 'package:flutter/material.dart';

class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with TickerProviderStateMixin {
  late AnimationController _squeezeController;
  late AnimationController _popController;
  late Animation<double> _squeezeAnimation;
  late Animation<double> _popAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Squeeze animation - elastic curve for bouncy squeeze effect
    _squeezeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Pop animation - for the final burst effect
    _popController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Scale animation with elastic curve for "tsubusu" effect
    _squeezeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3, // Squeeze down to 30% of original size
    ).animate(CurvedAnimation(
      parent: _squeezeController,
      curve: Curves.elasticIn, // Bouncy squeeze effect
    ));
    
    // Pop animation with bounce out
    _popAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.bounceOut, // Explosive pop effect
    ));
    
    // Color animation
    _colorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: widget.activeColor ?? Colors.teal,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _squeezeController.dispose();
    _popController.dispose();
    super.dispose();
  }

  void _animateCheck() async {
    if (!widget.value) {
      // Animate from unchecked to checked
      await _squeezeController.forward(); // First squeeze down
      await _popController.forward(); // Then pop back up with check
      widget.onChanged?.call(true); // Trigger the state change after animation completes
    } else {
      // Immediate toggle for unchecking
      widget.onChanged?.call(false);
      _squeezeController.reset();
      _popController.reset();
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only reset animations when this specific checkbox value changes externally
    // and it's being unchecked (not when other checkboxes trigger rebuilds)
    if (oldWidget.value != widget.value && !widget.value) {
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
          double scale;
          Color? backgroundColor;
          
          if (_squeezeController.isAnimating) {
            scale = _squeezeAnimation.value;
            backgroundColor = Colors.grey[300];
          } else if (_popController.isAnimating || widget.value) {
            scale = _popAnimation.value;
            backgroundColor = _colorAnimation.value;
          } else {
            scale = 1.0;
            backgroundColor = Colors.grey[300];
          }
          
          return Transform.scale(
            scale: scale,
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
                  if (_popController.isAnimating || widget.value)
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
          );
        },
      ),
    );
  }
}