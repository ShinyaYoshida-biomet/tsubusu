import 'package:flutter/material.dart';

enum ThemeType {
  forest,
  ocean,
  sunset,
  lavender,
  rose,
  cherry,
  mint,
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
    primaryColor: Color(0xFF2196F3),
    backgroundColor: Color(0xFFE3F2FD),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFBBDEFB),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFF90CAF9),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Sunset theme (orange/red-based)
  static const sunset = AppTheme(
    name: 'Sunset',
    type: ThemeType.sunset,
    primaryColor: Color(0xFFFF5722),
    backgroundColor: Color(0xFFFBE9E7),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFFFCCBC),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFFFF8A65),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Lavender theme (purple-based)
  static const lavender = AppTheme(
    name: 'Lavender',
    type: ThemeType.lavender,
    primaryColor: Color(0xFF9C27B0),
    backgroundColor: Color(0xFFF3E5F5),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFE1BEE7),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFFCE93D8),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Rose theme (pink-based)
  static const rose = AppTheme(
    name: 'Rose',
    type: ThemeType.rose,
    primaryColor: Color(0xFFE91E63),
    backgroundColor: Color(0xFFFCE4EC),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFF8BBD0),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFFF06292),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Cherry theme (red-based)
  static const cherry = AppTheme(
    name: 'Cherry',
    type: ThemeType.cherry,
    primaryColor: Colors.red,
    backgroundColor: Color(0xFFFFF5F5),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFFFEBEE),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFFEF9A9A),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  // Mint theme (mint green-based)
  static const mint = AppTheme(
    name: 'Mint',
    type: ThemeType.mint,
    primaryColor: Color(0xFF26A69A),
    backgroundColor: Color(0xFFF0FFF4),
    cardColor: Colors.white,
    textColor: Colors.black87,
    completedSectionColor: Color(0xFFE0F2F1),
    completedTextColor: Colors.grey,
    borderColor: Color(0xFF80CBC4),
    shadowColor: Color(0x0C000000),
    brightness: Brightness.light,
  );

  static const List<AppTheme> predefinedThemes = [
    forest,
    ocean,
    sunset,
    lavender,
    rose,
    cherry,
    mint,
  ];

  static AppTheme getTheme(ThemeType type) {
    switch (type) {
      case ThemeType.forest:
        return forest;
      case ThemeType.ocean:
        return ocean;
      case ThemeType.sunset:
        return sunset;
      case ThemeType.lavender:
        return lavender;
      case ThemeType.rose:
        return rose;
      case ThemeType.cherry:
        return cherry;
      case ThemeType.mint:
        return mint;
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