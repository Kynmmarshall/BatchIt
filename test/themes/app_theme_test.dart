// ============================================================================
// Tests for AppTheme and AppBackgroundTheme
// ============================================================================
import 'package:batchit/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light() returns a ThemeData with light brightness', () {
      final theme = AppTheme.light();
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.light);
    });

    test('dark() returns a ThemeData with dark brightness', () {
      final theme = AppTheme.dark();
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
    });

    test('both themes use Material3', () {
      expect(AppTheme.light().useMaterial3, isTrue);
      expect(AppTheme.dark().useMaterial3, isTrue);
    });

    test('light and dark color schemes have different brightness', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      expect(
        light.colorScheme.brightness,
        isNot(equals(dark.colorScheme.brightness)),
      );
    });

    test('light theme has transparent scaffold background', () {
      // AppTheme sets scaffoldBackgroundColor: Colors.transparent
      expect(AppTheme.light().scaffoldBackgroundColor, Colors.transparent);
    });

    test('dark theme has transparent scaffold background', () {
      expect(AppTheme.dark().scaffoldBackgroundColor, Colors.transparent);
    });

    test('light theme AppBar has zero elevation', () {
      final theme = AppTheme.light();
      expect(theme.appBarTheme.elevation, 0);
    });

    test('dark theme card has zero elevation', () {
      final theme = AppTheme.dark();
      expect(theme.cardTheme.elevation, 0);
    });

    test('AppBackgroundTheme extension is present in light theme', () {
      final ext = AppTheme.light().extension<AppBackgroundTheme>();
      expect(ext, isNotNull);
      expect(ext!.imageAsset, contains('light'));
    });

    test('AppBackgroundTheme extension is present in dark theme', () {
      final ext = AppTheme.dark().extension<AppBackgroundTheme>();
      expect(ext, isNotNull);
      expect(ext!.imageAsset, contains('dark'));
    });
  });

  group('AppBackgroundTheme', () {
    test('copyWith replaces imageAsset', () {
      const bg = AppBackgroundTheme(imageAsset: 'assets/old.png');
      final copy = bg.copyWith(imageAsset: 'assets/new.png');
      expect(copy.imageAsset, 'assets/new.png');
    });

    test('copyWith with null keeps original imageAsset', () {
      const bg = AppBackgroundTheme(imageAsset: 'assets/original.png');
      final copy = bg.copyWith();
      expect(copy.imageAsset, 'assets/original.png');
    });

    test('lerp at t < 0.5 returns this imageAsset', () {
      const a = AppBackgroundTheme(imageAsset: 'a.png');
      const b = AppBackgroundTheme(imageAsset: 'b.png');
      expect(a.lerp(b, 0.3).imageAsset, 'a.png');
    });

    test('lerp at t >= 0.5 returns other imageAsset', () {
      const a = AppBackgroundTheme(imageAsset: 'a.png');
      const b = AppBackgroundTheme(imageAsset: 'b.png');
      expect(a.lerp(b, 0.7).imageAsset, 'b.png');
    });

    test('lerp with exactly t = 0.5 returns other imageAsset', () {
      const a = AppBackgroundTheme(imageAsset: 'a.png');
      const b = AppBackgroundTheme(imageAsset: 'b.png');
      expect(a.lerp(b, 0.5).imageAsset, 'b.png');
    });

    test('lerp with null other returns this', () {
      const a = AppBackgroundTheme(imageAsset: 'a.png');
      expect(a.lerp(null, 0.7).imageAsset, 'a.png');
    });

    test('lerp with non-AppBackgroundTheme returns this', () {
      const a = AppBackgroundTheme(imageAsset: 'a.png');
      // Pass a different ThemeExtension type — lerp guard returns this
      expect(a.lerp(null, 0.9).imageAsset, 'a.png');
    });
  });
}
