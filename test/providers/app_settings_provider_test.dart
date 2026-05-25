// ============================================================================
// Tests for AppSettingsProvider
// ============================================================================
import 'package:batchit/providers/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppSettingsProvider provider;

  setUp(() => provider = AppSettingsProvider());

  group('initial state', () {
    test('locale defaults to en', () {
      expect(provider.locale, const Locale('en'));
    });

    test('themeMode defaults to system', () {
      expect(provider.themeMode, ThemeMode.system);
    });
  });

  group('setLocale', () {
    test('changes locale and notifies listeners', () {
      int notifications = 0;
      provider.addListener(() => notifications++);

      provider.setLocale(const Locale('fr'));

      expect(provider.locale, const Locale('fr'));
      expect(notifications, 1);
    });

    test('does not notify when same locale set', () {
      int notifications = 0;
      provider.addListener(() => notifications++);

      provider.setLocale(const Locale('en')); // already en

      expect(notifications, 0);
    });

    test('can switch back from fr to en', () {
      provider.setLocale(const Locale('fr'));
      provider.setLocale(const Locale('en'));
      expect(provider.locale, const Locale('en'));
    });
  });

  group('setTheme', () {
    test('changes themeMode and notifies', () {
      int notifications = 0;
      provider.addListener(() => notifications++);

      provider.setTheme(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(notifications, 1);
    });

    test('does not notify when same mode set', () {
      int notifications = 0;
      provider.setTheme(ThemeMode.light); // change first
      provider.addListener(() => notifications++);

      provider.setTheme(ThemeMode.light); // same — no notification

      expect(notifications, 0);
    });

    test('can be set to light', () {
      provider.setTheme(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('can be set to system', () {
      provider.setTheme(ThemeMode.dark);
      provider.setTheme(ThemeMode.system);
      expect(provider.themeMode, ThemeMode.system);
    });
  });

  group('applyTheme', () {
    test('applies a theme mode', () {
      provider.applyTheme(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('does not notify when same mode applied', () {
      provider.applyTheme(ThemeMode.light);
      int notifications = 0;
      provider.addListener(() => notifications++);
      provider.applyTheme(ThemeMode.light);
      expect(notifications, 0);
    });
  });

  group('toggleTheme', () {
    test('cycles system → light', () {
      // starts at system
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
    });

    test('cycles light → dark', () {
      provider.setTheme(ThemeMode.light);
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('cycles dark → system', () {
      provider.setTheme(ThemeMode.dark);
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('full cycle returns to system', () {
      // system → light → dark → system
      provider.toggleTheme();
      provider.toggleTheme();
      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('notifies listeners on each toggle', () {
      int notifications = 0;
      provider.addListener(() => notifications++);
      provider.toggleTheme();
      provider.toggleTheme();
      expect(notifications, 2);
    });
  });
}
