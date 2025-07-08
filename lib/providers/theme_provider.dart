import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  
  AppTheme _currentTheme = AppTheme.forest; // Default to Forest theme
  
  AppTheme get currentTheme => _currentTheme;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeTypeString = prefs.getString(_themeKey);
      
      if (themeTypeString != null) {
        final themeType = ThemeType.values.firstWhere(
          (e) => e.toString() == themeTypeString,
          orElse: () => ThemeType.forest,
        );
        
        _currentTheme = AppTheme.getTheme(themeType);
      }
    } catch (e) {
      // If loading fails, use default Forest theme
      _currentTheme = AppTheme.forest;
    }
    notifyListeners();
  }
  
  Future<void> setTheme(ThemeType themeType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeType.toString());
      
      _currentTheme = AppTheme.getTheme(themeType);
      
      notifyListeners();
    } catch (e) {
      // Handle error gracefully
      debugPrint('Failed to save theme: $e');
    }
  }
  
  ThemeData get themeData => _currentTheme.toThemeData();
  
  // Helper method to get theme-aware colors for widgets
  Color get primaryColor => _currentTheme.primaryColor;
  Color get backgroundColor => _currentTheme.backgroundColor;
  Color get cardColor => _currentTheme.cardColor;
  Color get textColor => _currentTheme.textColor;
  Color get completedSectionColor => _currentTheme.completedSectionColor;
  Color get completedTextColor => _currentTheme.completedTextColor;
  Color get borderColor => _currentTheme.borderColor;
  Color get shadowColor => _currentTheme.shadowColor;
}