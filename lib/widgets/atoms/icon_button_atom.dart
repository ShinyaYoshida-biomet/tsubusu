import 'package:flutter/material.dart';

class IconButtonAtom extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;

  const IconButtonAtom({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: iconColor, size: size),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
    );
  }
}