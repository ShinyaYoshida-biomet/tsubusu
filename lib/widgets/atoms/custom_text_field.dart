import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<String>? onSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.style,
    this.hintStyle,
    this.fillColor,
    this.filled = false,
    this.border,
    this.contentPadding,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: style,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        filled: filled,
        fillColor: fillColor,
        border: border,
        contentPadding: contentPadding,
      ),
      onSubmitted: onSubmitted,
    );
  }
}