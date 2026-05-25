// ============================================================================
// Tests for AppNotification model
// ============================================================================
import 'package:batchit/models/notification_item.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> baseJson({
  String id = 'n1',
  String type = 'batch_full',
  bool isRead = false,
  String? relatedBatch,
}) =>
    {
      'id': id,
      'title': 'Batch Ready!',
      'body': 'Your batch has been filled.',
      'notification_type': type,
      'is_read': isRead,
      'created_at': '2024-03-10T08:00:00Z',
      if (relatedBatch != null) 'related_batch': relatedBatch,
    };

void main() {
  group('AppNotification.fromJson', () {
    test('parses all required fields', () {
      final n = AppNotification.fromJson(baseJson());
      expect(n.id, 'n1');
      expect(n.title, 'Batch Ready!');
      expect(n.body, 'Your batch has been filled.');
      expect(n.type, 'batch_full');
      expect(n.isRead, false);
      expect(n.createdAt, DateTime.parse('2024-03-10T08:00:00Z'));
      expect(n.relatedBatchId, isNull);
    });

    test('parses relatedBatchId when present', () {
      final n = AppNotification.fromJson(baseJson(relatedBatch: 'batch-99'));
      expect(n.relatedBatchId, 'batch-99');
    });

    test('isRead true when JSON says true', () {
      final n = AppNotification.fromJson(baseJson(isRead: true));
      expect(n.isRead, true);
    });

    test('notification_type falls back to general when absent', () {
      final json = baseJson();
      json.remove('notification_type');
      final n = AppNotification.fromJson(json);
      expect(n.type, 'general');
    });

    test('is_read falls back to false when absent', () {
      final json = baseJson();
      json.remove('is_read');
      final n = AppNotification.fromJson(json);
      expect(n.isRead, false);
    });
  });

  group('AppNotification.copyWith', () {
    test('copyWith(isRead: true) marks as read', () {
      final n = AppNotification.fromJson(baseJson(isRead: false));
      final updated = n.copyWith(isRead: true);
      expect(updated.isRead, true);
      expect(updated.id, n.id); // other fields unchanged
      expect(updated.title, n.title);
    });

    test('copyWith without argument preserves isRead', () {
      final n = AppNotification.fromJson(baseJson(isRead: true));
      final copy = n.copyWith();
      expect(copy.isRead, true);
    });
  });
}
