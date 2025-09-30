import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../atoms/custom_text.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ThemeType _selectedThemeType;

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _selectedThemeType = themeProvider.currentTheme.type;
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
            ...AppTheme.predefinedThemes.map((theme) => RadioListTile<ThemeType>(
                  title: CustomText(theme.displayName),
                  value: theme.type,
                  groupValue: _selectedThemeType,
                  onChanged: _handleThemeChange,
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
}