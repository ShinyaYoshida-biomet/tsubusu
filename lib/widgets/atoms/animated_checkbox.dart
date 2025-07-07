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
  bool _isAnimating = false; // Track animation state

  @override
  void initState() {
    super.initState();
    
    // Squeeze animation - longer duration for more "tsubusu" feeling
    _squeezeController = AnimationController(
      duration: const Duration(milliseconds: 500), // Increased from 300ms
      vsync: this,
    );
    
    // Pop animation - for the final burst effect
    _popController = AnimationController(
      duration: const Duration(milliseconds: 300), // Slightly faster pop
      vsync: this,
    );
    
    // Scale animation with elastic curve for "tsubusu" effect
    _squeezeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1, // Squeeze down to 10% of original size for more "crushing" feel
    ).animate(CurvedAnimation(
      parent: _squeezeController,
      curve: Curves.easeInQuart, // Smooth, accelerating squeeze for crushing feeling
    ));
    
    // Pop animation with bounce out
    _popAnimation = Tween<double>(
      begin: 0.1, // Start from the same crushed size
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut, // More elastic pop for satisfying release
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
    // Prevent multiple simultaneous animations
    if (_isAnimating) return;
    
    if (!widget.value) {
      setState(() {
        _isAnimating = true;
      });
      
      try {
        // Animate from unchecked to checked
        await _squeezeController.forward(); // First squeeze down
        await _popController.forward(); // Then pop back up with check
        widget.onChanged?.call(true); // Trigger the state change after animation completes
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
          double scale;
          Color? backgroundColor;
          
          if (_squeezeController.isAnimating) {
            scale = _squeezeAnimation.value;
            backgroundColor = Colors.grey[300];
          } else if (_popController.isAnimating) {
            scale = _popAnimation.value;
            backgroundColor = _colorAnimation.value;
          } else if (widget.value) {
            // Keep the completed state styling
            scale = 1.0;
            backgroundColor = widget.activeColor ?? Colors.teal;
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