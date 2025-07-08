import 'package:flutter/material.dart';

enum ThemeType {
  forest,
  ocean,
  sunset,
  midnight,
  system,
}

class AppTheme {
  final String name;
  final ThemeType type;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color completedSectionColor;
  final Color completedTextColor;
  final Color borderColor;
  final Color shadowColor;
  final Brightness brightness;

  const AppTheme({
    required this.name,
    required this.type,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.completedSectionColor,
    required this.completedTextColor,
    required this.borderColor,
    required this.shadowColor,
    required this.brightness,
  });

  // Forest theme (current green-based UI)
  static const forest = AppTheme(
    name: 'Forest',
    type: ThemeType.forest,
    primaryColor: Colors.teal,
    backgroundColor: Color(0xFFF5F5F5),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFE8F5E8),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFFE0E0E0),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Ocean theme (blue-based)
  static const ocean = AppTheme(
    name: 'Ocean',
    type: ThemeType.ocean,
    primaryColor: Colors.blue,
    backgroundColor: Color(0xFFF0F8FF),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFE6F3FF),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFFB3D9FF),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Sunset theme (orange/red-based)
  static const sunset = AppTheme(
    name: 'Sunset',
    type: ThemeType.sunset,
    primaryColor: Colors.deepOrange,
    backgroundColor: Color(0xFFFFF8F0),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFFFE6D9),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFFFFB380),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Midnight theme (dark theme)
  static const midnight = AppTheme(
    name: 'Midnight',
    type: ThemeType.midnight,
    primaryColor: Color(0xFF64B5F6),
    backgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    textColor: Colors.white,
    completedSectionColor: Color(0xFF2D2D2D),
    completedTextColor: Color(0xFF888888),
    borderColor: Color(0xFF404040),
    shadowColor: Color(0x33000000),
    brightness: Brightness.dark,
  );

  static const List<AppTheme> predefinedThemes = [
    forest,
    ocean,
    sunset,
    midnight,
  ];

  static AppTheme getTheme(ThemeType type) {
    switch (type) {
      case ThemeType.forest:
        return forest;
      case ThemeType.ocean:
        return ocean;
      case ThemeType.sunset:
        return sunset;
      case ThemeType.midnight:
        return midnight;
      case ThemeType.system:
        // Return appropriate theme based on system brightness
        return forest; // Default fallback
    }
  }

  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        titleMedium: TextStyle(color: textColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        surface: cardColor,
        onSurface: textColor,
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = (color.r * 255).round(), 
              g = (color.g * 255).round(), 
              b = (color.b * 255).round();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}