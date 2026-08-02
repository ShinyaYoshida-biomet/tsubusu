import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../atoms/custom_text.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback? onOpenTaskHistory;

  const SettingsDialog({super.key, this.onOpenTaskHistory});

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
    return AlertDialog.adaptive(
      title: const CustomText('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              'Task data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const CustomText('Task history'),
              trailing: const Icon(Icons.history),
              onTap: () {
                Navigator.pop(context);
                widget.onOpenTaskHistory?.call();
              },
            ),
            const SizedBox(height: 8),
            const CustomText(
              'Theme:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...AppTheme.predefinedThemes.map(
              (theme) => RadioListTile<ThemeType>(
                title: CustomText(theme.displayName),
                value: theme.type,
                groupValue: _selectedThemeType,
                onChanged: _handleThemeChange,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
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
