/// Delivery state of a message I sent (incoming messages ignore it).
enum MessageStatus { sending, sent, delivered, read }

/// A single 1:1 chat message. Shape is provisional until the chat API/socket
/// exists.
/// TODO(api): add fromJson/toJson once the chat API shape is known.
class ChatMessage {
  final String id;
  final String text;
  final bool isMine;
  final DateTime sentAt;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.sentAt,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
        id: id,
        text: text,
        isMine: isMine,
        sentAt: sentAt,
        status: status ?? this.status,
      );
}
