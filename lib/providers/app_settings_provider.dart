/// ============================================================================
/// [AppSettingsProvider] - Manages global application settings
/// ============================================================================
/// Extends ChangeNotifier to provide reactive state management for app config.
/// Stores and exposes theme mode (light/dark) and locale (EN/FR).
///
/// Responsibilities:
/// - Maintain current locale setting (_locale, defaults to 'en')
/// - Maintain current theme mode (_themeMode, defaults to light)
/// - Provide setters that notify listeners on changes
/// - Persist settings for app reload (TODO: shared_preferences)
///
/// Dependencies: None (no external services)
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppSettingsProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  late final Box _settingsBox;

  AppSettingsProvider() {
    _settingsBox = Hive.box('settings');
    // Load persisted settings if present
    final persistedLocale = _settingsBox.get('locale') as String?;
    final persistedTheme = _settingsBox.get('theme_mode') as String?;
    if (persistedLocale != null && persistedLocale.isNotEmpty) {
      _locale = Locale(persistedLocale);
    }
    if (persistedTheme != null && persistedTheme.isNotEmpty) {
      _themeMode = switch (persistedTheme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    }
  }

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  /// Changes app locale if different from current, notifies listeners.
  /// Early return if new locale same as current to avoid unnecessary rebuilds.
  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    _settingsBox.put('locale', locale.languageCode);
    notifyListeners();
  }

  /// Cycles theme: system → light → dark → system.
  /// Called when user taps theme toggle in settings.
  void toggleTheme() {
    _themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    _settingsBox.put(
      'theme_mode',
      _themeMode == ThemeMode.light
          ? 'light'
          : _themeMode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
    notifyListeners();
  }

  /// Sets theme mode directly (e.g. system, light, dark).
  void setTheme(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _settingsBox.put(
      'theme_mode',
      _themeMode == ThemeMode.light
          ? 'light'
          : _themeMode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
    notifyListeners();
  }

  /// Applies a specific theme mode directly (used when loading persisted settings).
  void applyTheme(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _settingsBox.put(
      'theme_mode',
      _themeMode == ThemeMode.light
          ? 'light'
          : _themeMode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
    notifyListeners();
  }
}
