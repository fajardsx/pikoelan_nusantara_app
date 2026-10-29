class ChatMessage {
  final String userId;
  final String message;
  final String timestamp;

  ChatMessage({
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      userId: json['userId'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'message': message, 'timestamp': timestamp};
  }
}
