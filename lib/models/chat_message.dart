class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String? ?? '',
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }
}
