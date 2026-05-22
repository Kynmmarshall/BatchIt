import 'package:batchit/models/chat_message.dart';
import 'package:batchit/services/api_client.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final ApiClient _api = ApiClient();

  Future<List<ChatMessage>> fetchMessages(String batchId) async {
    try {
      final response = await _api.get('/batches/$batchId/chat/messages/');
      final items = response is List ? response : [];
      return items
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ChatService] fetchMessages error: $e');
      return [];
    }
  }

  Future<ChatMessage> sendMessage(String batchId, String content) async {
    final response = await _api.post(
      '/batches/$batchId/chat/messages/',
      body: {'content': content},
    );
    return ChatMessage.fromJson(response as Map<String, dynamic>);
  }

  /// Joins the chat room (and ensures membership) for a batch.
  Future<void> joinRoom(String batchId) async {
    try {
      await _api.get('/batches/$batchId/chat/');
    } catch (e) {
      debugPrint('[ChatService] joinRoom error: $e');
    }
  }
}
