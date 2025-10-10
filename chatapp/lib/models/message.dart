
class Message {
  final String role; // "user" or "assistant"
  final String content;
  final DateTime timestamp;
  final String sessionId; // chat session identifier

  Message({
    required this.role,
    required this.content,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'sessionId': sessionId,
      };

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        role: map['role'] ?? 'user',
        content: map['content'] ?? '',
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
        sessionId: map['sessionId'] ?? 'default',
      );
}
