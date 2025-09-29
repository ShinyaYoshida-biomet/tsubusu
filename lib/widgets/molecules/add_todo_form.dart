import 'package:flutter/material.dart';
import '../../constants/design_constants.dart';
import '../atoms/custom_text_field.dart';

class AddTodoForm extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;

  const AddTodoForm({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(color: Colors.white),
      hintText: 'Add a new task...',
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: DesignConstants.opacityHeavy)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: DesignConstants.opacityLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusStandard),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: DesignConstants.spacingMedium, vertical: DesignConstants.spacingSmall),
      onSubmitted: (_) => onAdd(),
    );
  }
}