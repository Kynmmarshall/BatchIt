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

class AppSettingsProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  /// Changes app locale if different from current, notifies listeners.
  /// Early return if new locale same as current to avoid unnecessary rebuilds.
  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
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
    notifyListeners();
  }

  /// Sets theme mode directly (e.g. system, light, dark).
  void setTheme(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Applies a specific theme mode directly (used when loading persisted settings).
  void applyTheme(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }
}
