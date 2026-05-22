import 'package:batchit/models/user_settings.dart';
import 'package:batchit/services/api_client.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  final ApiClient _api = ApiClient();

  Future<UserSettings> fetchSettings() async {
    try {
      final response = await _api.get('/settings/');
      return UserSettings.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[SettingsService] fetchSettings error: $e');
      return const UserSettings();
    }
  }

  Future<UserSettings> updateSettings(Map<String, dynamic> fields) async {
    try {
      final response = await _api.patch('/settings/', body: fields);
      return UserSettings.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[SettingsService] updateSettings error: $e');
      rethrow;
    }
  }
}
