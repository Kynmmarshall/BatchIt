import 'package:batchit/models/notification_item.dart';
import 'package:batchit/services/api_client.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await _api.get('/notifications/');
      final items = response is List ? response : [];
      return items
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[NotificationService] fetchNotifications error: $e');
      return [];
    }
  }

  Future<void> markRead(String notifId) async {
    try {
      await _api.patch('/notifications/$notifId/', body: {});
    } catch (e) {
      debugPrint('[NotificationService] markRead error: $e');
    }
  }
}
