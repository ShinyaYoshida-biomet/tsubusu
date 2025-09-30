import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsubusu/models/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('predefinedThemes', () {
      test('should contain all theme types', () {
        expect(AppTheme.predefinedThemes.length, ThemeType.values.length);
      });

      test('should have unique theme types', () {
        final types = AppTheme.predefinedThemes.map((t) => t.type).toSet();
        expect(types.length, AppTheme.predefinedThemes.length);
      });

      test('should have valid displayNames', () {
        for (final theme in AppTheme.predefinedThemes) {
          expect(theme.displayName, isNotEmpty);
          expect(theme.displayName, contains('('));
          expect(theme.displayName, contains(')'));
        }
      });
    });

    group('getTheme', () {
      test('should return forest theme for ThemeType.forest', () {
        final theme = AppTheme.getTheme(ThemeType.forest);
        expect(theme.type, ThemeType.forest);
        expect(theme.name, 'Forest');
        expect(theme.displayName, 'Forest (Green)');
      });

      test('should return ocean theme for ThemeType.ocean', () {
        final theme = AppTheme.getTheme(ThemeType.ocean);
        expect(theme.type, ThemeType.ocean);
        expect(theme.name, 'Ocean');
        expect(theme.displayName, 'Ocean (Blue)');
      });

      test('should return sunset theme for ThemeType.sunset', () {
        final theme = AppTheme.getTheme(ThemeType.sunset);
        expect(theme.type, ThemeType.sunset);
        expect(theme.name, 'Sunset');
        expect(theme.displayName, 'Sunset (Orange)');
      });

      test('should return lavender theme for ThemeType.lavender', () {
        final theme = AppTheme.getTheme(ThemeType.lavender);
        expect(theme.type, ThemeType.lavender);
        expect(theme.name, 'Lavender');
        expect(theme.displayName, 'Lavender (Purple)');
      });

      test('should return rose theme for ThemeType.rose', () {
        final theme = AppTheme.getTheme(ThemeType.rose);
        expect(theme.type, ThemeType.rose);
        expect(theme.name, 'Rose');
        expect(theme.displayName, 'Rose (Pink)');
      });

      test('should return cherry theme for ThemeType.cherry', () {
        final theme = AppTheme.getTheme(ThemeType.cherry);
        expect(theme.type, ThemeType.cherry);
        expect(theme.name, 'Cherry');
        expect(theme.displayName, 'Cherry (Red)');
      });

      test('should return mint theme for ThemeType.mint', () {
        final theme = AppTheme.getTheme(ThemeType.mint);
        expect(theme.type, ThemeType.mint);
        expect(theme.name, 'Mint');
        expect(theme.displayName, 'Mint (Green)');
      });
    });

    group('theme properties', () {
      test('forest theme should have correct colors', () {
        expect(AppTheme.forest.primaryColor, Colors.teal);
        expect(AppTheme.forest.backgroundColor, const Color(0xFFF5F5F5));
        expect(AppTheme.forest.cardColor, Colors.white);
        expect(AppTheme.forest.brightness, Brightness.light);
      });

      test('ocean theme should have correct colors', () {
        expect(AppTheme.ocean.primaryColor, const Color(0xFF2196F3));
        expect(AppTheme.ocean.backgroundColor, const Color(0xFFE3F2FD));
      });

      test('all themes should have light brightness', () {
        for (final theme in AppTheme.predefinedThemes) {
          expect(theme.brightness, Brightness.light);
        }
      });

      test('all themes should have non-null colors', () {
        for (final theme in AppTheme.predefinedThemes) {
          expect(theme.primaryColor, isNotNull);
          expect(theme.backgroundColor, isNotNull);
          expect(theme.cardColor, isNotNull);
          expect(theme.textColor, isNotNull);
          expect(theme.completedSectionColor, isNotNull);
          expect(theme.completedTextColor, isNotNull);
          expect(theme.borderColor, isNotNull);
          expect(theme.shadowColor, isNotNull);
        }
      });
    });

    group('toThemeData', () {
      test('should create valid ThemeData', () {
        final themeData = AppTheme.forest.toThemeData();
        expect(themeData, isNotNull);
        expect(themeData.brightness, Brightness.light);
        expect(themeData.primaryColor, Colors.teal);
      });

      test('should create ThemeData with correct scaffold background', () {
        final themeData = AppTheme.ocean.toThemeData();
        expect(themeData.scaffoldBackgroundColor, const Color(0xFFE3F2FD));
      });

      test('should handle all predefined themes', () {
        for (final theme in AppTheme.predefinedThemes) {
          final themeData = theme.toThemeData();
          expect(themeData, isNotNull);
          expect(themeData.brightness, theme.brightness);
          expect(themeData.primaryColor, theme.primaryColor);
        }
      });
    });

    group('_createMaterialColor', () {
      test('should create material color from theme', () {
        final themeData = AppTheme.forest.toThemeData();
        // MaterialColor should be created without errors
        expect(themeData.primaryColor, isNotNull);
      });

      test('should handle different colors', () {
        for (final theme in AppTheme.predefinedThemes) {
          final themeData = theme.toThemeData();
          expect(themeData.primaryColor, isNotNull);
        }
      });
    });
  });
}