// ============================================================================
// Tests for ChatMessage model
// ============================================================================
import 'package:batchit/models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage.fromJson', () {
    test('parses all fields correctly', () {
      final m = ChatMessage.fromJson({
        'id': 'msg-1',
        'sender_id': 'user-42',
        'sender_name': 'Alice',
        'content': 'Hello!',
        'sent_at': '2024-05-01T12:00:00Z',
      });
      expect(m.id, 'msg-1');
      expect(m.senderId, 'user-42');
      expect(m.senderName, 'Alice');
      expect(m.content, 'Hello!');
      expect(m.sentAt, DateTime.parse('2024-05-01T12:00:00Z'));
    });

    test('senderName falls back to empty string when absent', () {
      final m = ChatMessage.fromJson({
        'id': 'msg-2',
        'sender_id': 'user-1',
        'content': 'Hi',
        'sent_at': '2024-05-01T12:00:00Z',
      });
      expect(m.senderName, '');
    });

    test('senderName falls back to empty string when null', () {
      final m = ChatMessage.fromJson({
        'id': 'msg-3',
        'sender_id': 'user-1',
        'sender_name': null,
        'content': 'Hey',
        'sent_at': '2024-05-01T12:00:00Z',
      });
      expect(m.senderName, '');
    });

    test('constructor stores all fields', () {
      final sentAt = DateTime(2024, 6, 1);
      final m = ChatMessage(
        id: 'x',
        senderId: 's',
        senderName: 'Bob',
        content: 'World',
        sentAt: sentAt,
      );
      expect(m.id, 'x');
      expect(m.sentAt, sentAt);
    });
  });

  group('ChatMessage construction', () {
    test('can be created with all required fields', () {
      final sentAt = DateTime(2024, 1, 1);
      final m = ChatMessage(
        id: 'id1',
        senderId: 'sid',
        senderName: 'Carol',
        content: 'Test message',
        sentAt: sentAt,
      );
      expect(m.id, 'id1');
      expect(m.senderId, 'sid');
      expect(m.senderName, 'Carol');
      expect(m.content, 'Test message');
      expect(m.sentAt, sentAt);
    });
  });
}
