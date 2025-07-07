import 'package:flutter/material.dart';
import '../../models/animation_type.dart';
import '../../services/preferences_service.dart';
import '../atoms/custom_text.dart';

class SettingsDialog extends StatefulWidget {
  final AnimationType currentAnimationType;
  final ValueChanged<AnimationType> onAnimationTypeChanged;

  const SettingsDialog({
    super.key,
    required this.currentAnimationType,
    required this.onAnimationTypeChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AnimationType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentAnimationType;
  }

  void _handleAnimationTypeChange(AnimationType? type) async {
    if (type != null) {
      await PreferencesService.setAnimationType(type);
      setState(() {
        _selectedType = type;
      });
      widget.onAnimationTypeChanged(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CustomText('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText('Animation Type:'),
          const SizedBox(height: 12),
          ...AnimationType.values.map((type) => RadioListTile<AnimationType>(
                title: CustomText(type.displayName),
                value: type,
                groupValue: _selectedType,
                onChanged: _handleAnimationTypeChange,
              )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const CustomText('Close'),
        ),
      ],
    );
  }
}