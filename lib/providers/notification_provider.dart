import 'package:batchit/models/notification_item.dart';
import 'package:batchit/services/notification_service.dart';
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _notifications = await _service.fetchNotifications();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markRead(String notifId) async {
    await _service.markRead(notifId);
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _notifications = List.of(_notifications)
        ..[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    for (final n in _notifications.where((n) => !n.isRead)) {
      await _service.markRead(n.id);
    }
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }
}
