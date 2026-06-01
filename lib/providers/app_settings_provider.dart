/// ============================================================================
/// [AppSettingsProvider] - Manages global application settings with persistence
/// ============================================================================
/// Extends ChangeNotifier to provide reactive state management for app config.
/// Persists theme mode (light/dark) and locale (EN/FR) to Hive storage.
///
/// Responsibilities:
/// - Maintain current locale setting (_locale, defaults to 'en')
/// - Maintain current theme mode (_themeMode, defaults to light)
/// - Persist settings to Hive on every change
/// - Load persisted settings on initialization
/// - Provide setters that notify listeners on changes
///
/// Dependencies: HiveService for storage
/// ============================================================================
library;

import 'package:batchit/services/hive_service.dart';
import 'package:flutter/material.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider(this._hiveService) {
    _loadSettings();
  }

  final HiveService _hiveService;

  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  /// Loads persisted settings from Hive storage.
  /// Called during initialization to restore user preferences.
  /// Falls back to defaults if settings not found.
  void _loadSettings() {
    try {
      final savedLocale = _hiveService.getAppSetting('locale');
      if (savedLocale != null && savedLocale is String) {
        _locale = Locale(savedLocale);
        debugPrint('[AppSettingsProvider] Loaded locale: $savedLocale');
      }

      final savedThemeMode = _hiveService.getAppSetting('themeMode');
      if (savedThemeMode != null && savedThemeMode is String) {
        _themeMode = savedThemeMode == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light;
        debugPrint('[AppSettingsProvider] Loaded theme mode: $savedThemeMode');
      }
    } catch (e) {
      debugPrint('[AppSettingsProvider] Error loading settings: $e');
    }
  }

  /// Changes app locale if different from current, persists and notifies.
  /// Early return if new locale same as current to avoid unnecessary operations.
  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    _saveLocale(locale.languageCode);
    notifyListeners();
  }

  /// Toggles theme between light and dark mode, persists and notifies.
  /// Called when user taps theme toggle in settings.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeMode(_themeMode.toString().split('.').last);
    notifyListeners();
  }

  /// Persists locale setting to Hive asynchronously.
  Future<void> _saveLocale(String languageCode) async {
    try {
      await _hiveService.saveAppSetting('locale', languageCode);
    } catch (e) {
      debugPrint('[AppSettingsProvider] Error saving locale: $e');
    }
  }

  /// Persists theme mode setting to Hive asynchronously.
  Future<void> _saveThemeMode(String mode) async {
    try {
      await _hiveService.saveAppSetting('themeMode', mode);
    } catch (e) {
      debugPrint('[AppSettingsProvider] Error saving theme mode: $e');
    }
  }
}
