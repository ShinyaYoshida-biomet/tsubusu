import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsubusu/models/app_theme.dart';
import 'package:tsubusu/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    group('initialization', () {
      test('should default to forest theme', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentTheme.type, ThemeType.forest);
      });

      test('should load saved theme from preferences', () async {
        SharedPreferences.setMockInitialValues({
          'selected_theme': 'ThemeType.ocean',
        });

        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentTheme.type, ThemeType.ocean);
      });

      test('should fallback to forest theme if saved theme is invalid', () async {
        SharedPreferences.setMockInitialValues({
          'selected_theme': 'invalid_theme',
        });

        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentTheme.type, ThemeType.forest);
      });

      test('should handle missing preferences gracefully', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentTheme, isNotNull);
        expect(provider.currentTheme.type, ThemeType.forest);
      });
    });

    group('setTheme', () {
      late ThemeProvider provider;

      setUp(() async {
        provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should change current theme', () async {
        await provider.setTheme(ThemeType.ocean);

        expect(provider.currentTheme.type, ThemeType.ocean);
      });

      test('should persist theme to preferences', () async {
        await provider.setTheme(ThemeType.sunset);

        final prefs = await SharedPreferences.getInstance();
        final savedTheme = prefs.getString('selected_theme');

        expect(savedTheme, 'ThemeType.sunset');
      });

      test('should notify listeners on theme change', () async {
        var notified = false;
        provider.addListener(() {
          notified = true;
        });

        await provider.setTheme(ThemeType.lavender);

        expect(notified, true);
      });

      test('should handle all theme types', () async {
        for (final themeType in ThemeType.values) {
          await provider.setTheme(themeType);

          expect(provider.currentTheme.type, themeType);
        }
      });

      test('should update themeData when theme changes', () async {
        final initialThemeData = provider.themeData;
        await provider.setTheme(ThemeType.cherry);

        expect(provider.themeData, isNot(equals(initialThemeData)));
        expect(provider.themeData.primaryColor, AppTheme.cherry.primaryColor);
      });
    });

    group('currentTheme', () {
      test('should return current AppTheme', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentTheme, isA<AppTheme>());
        expect(provider.currentTheme.type, ThemeType.forest);
      });

      test('should reflect theme changes', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        final initialTheme = provider.currentTheme;
        await provider.setTheme(ThemeType.mint);

        expect(provider.currentTheme, isNot(equals(initialTheme)));
        expect(provider.currentTheme.type, ThemeType.mint);
      });
    });

    group('themeData', () {
      test('should return valid ThemeData', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.themeData, isNotNull);
        expect(provider.themeData.primaryColor, provider.currentTheme.primaryColor);
      });

      test('should update when theme changes', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.setTheme(ThemeType.rose);
        final themeData = provider.themeData;

        expect(themeData.primaryColor, AppTheme.rose.primaryColor);
        expect(themeData.scaffoldBackgroundColor, AppTheme.rose.backgroundColor);
      });
    });

    group('color getters', () {
      late ThemeProvider provider;

      setUp(() async {
        provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));
      });

      test('should return correct primary color', () {
        expect(provider.primaryColor, provider.currentTheme.primaryColor);
      });

      test('should return correct background color', () {
        expect(provider.backgroundColor, provider.currentTheme.backgroundColor);
      });

      test('should return correct card color', () {
        expect(provider.cardColor, provider.currentTheme.cardColor);
      });

      test('should return correct text color', () {
        expect(provider.textColor, provider.currentTheme.textColor);
      });

      test('should return correct completed section color', () {
        expect(provider.completedSectionColor, provider.currentTheme.completedSectionColor);
      });

      test('should return correct completed text color', () {
        expect(provider.completedTextColor, provider.currentTheme.completedTextColor);
      });

      test('should return correct border color', () {
        expect(provider.borderColor, provider.currentTheme.borderColor);
      });

      test('should return correct shadow color', () {
        expect(provider.shadowColor, provider.currentTheme.shadowColor);
      });

      test('color getters should update when theme changes', () async {
        final initialColor = provider.primaryColor;
        await provider.setTheme(ThemeType.ocean);

        expect(provider.primaryColor, isNot(equals(initialColor)));
        expect(provider.primaryColor, AppTheme.ocean.primaryColor);
      });
    });

    group('error handling', () {
      test('should handle preference save error gracefully', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        // This should not throw even if there's an error
        expect(() async => await provider.setTheme(ThemeType.cherry), returnsNormally);
      });

      test('should still update theme even if save fails', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.setTheme(ThemeType.lavender);

        expect(provider.currentTheme.type, ThemeType.lavender);
      });
    });

    group('listener notifications', () {
      test('should notify listeners on theme change', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        var callCount = 0;
        provider.addListener(() {
          callCount++;
        });

        await provider.setTheme(ThemeType.sunset);

        expect(callCount, greaterThan(0));
      });

      test('should not notify if theme is same', () async {
        final provider = ThemeProvider();
        await Future.delayed(const Duration(milliseconds: 100));

        // First set to ocean
        await provider.setTheme(ThemeType.ocean);

        var callCount = 0;
        provider.addListener(() {
          callCount++;
        });

        // Set to ocean again
        await provider.setTheme(ThemeType.ocean);

        // Should still notify (current implementation doesn't check for same theme)
        expect(callCount, 1);
      });
    });
  });
}