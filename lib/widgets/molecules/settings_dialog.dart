import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/animation_type.dart';
import '../../models/app_theme.dart';
import '../../providers/theme_provider.dart';
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
  late AnimationType _selectedAnimationType;
  late ThemeType _selectedThemeType;

  @override
  void initState() {
    super.initState();
    _selectedAnimationType = widget.currentAnimationType;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _selectedThemeType = themeProvider.isSystemTheme 
        ? ThemeType.system 
        : themeProvider.currentTheme.type;
  }

  void _handleAnimationTypeChange(AnimationType? type) async {
    if (type != null) {
      await PreferencesService.setAnimationType(type);
      setState(() {
        _selectedAnimationType = type;
      });
      widget.onAnimationTypeChanged(type);
    }
  }

  void _handleThemeChange(ThemeType? themeType) async {
    if (themeType != null) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.setTheme(themeType);
      setState(() {
        _selectedThemeType = themeType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const CustomText('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Selection Section
            const CustomText('Theme:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...ThemeType.values.map((type) => RadioListTile<ThemeType>(
                  title: CustomText(_getThemeDisplayName(type)),
                  subtitle: type == ThemeType.system 
                      ? const CustomText('Follows system settings', style: TextStyle(fontSize: 12))
                      : null,
                  value: type,
                  groupValue: _selectedThemeType,
                  onChanged: _handleThemeChange,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                )),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Animation Type Selection Section
            const CustomText('Animation Type:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...AnimationType.values.map((type) => RadioListTile<AnimationType>(
                  title: CustomText(type.displayName),
                  value: type,
                  groupValue: _selectedAnimationType,
                  onChanged: _handleAnimationTypeChange,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const CustomText('Close'),
        ),
      ],
    );
  }

  String _getThemeDisplayName(ThemeType type) {
    switch (type) {
      case ThemeType.forest:
        return 'Forest (Green)';
      case ThemeType.ocean:
        return 'Ocean (Blue)';
      case ThemeType.sunset:
        return 'Sunset (Orange)';
      case ThemeType.midnight:
        return 'Midnight (Dark)';
      case ThemeType.system:
        return 'System Default';
    }
  }
}