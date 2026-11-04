/// Delivery state of a message I sent (incoming messages ignore it).
/// `failed` is first so the "never downgrade" index checks stay valid for the
/// real progression sending → sent → delivered → read.
enum MessageStatus { failed, sending, sent, delivered, read }

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

  /// Parses one item of GET conversations/{id}/messages. Returns null when
  /// the item has no id. [isMine] decides left/right (see
  /// ChatController.isMineMessage). Missing fields fall back to safe values.
  static ChatMessage? fromApiJson(
    Map<String, dynamic> json, {
    required bool Function(Map<String, dynamic> json) isMine,
  }) {
    final String id = json['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    final String? created = json['created_at'] is String
        ? json['created_at'] as String
        : null;
    return ChatMessage(
      id: id,
      text: json['content']?.toString() ?? '',
      isMine: isMine(json),
      sentAt: (created == null ? null : DateTime.tryParse(created)?.toLocal()) ??
          DateTime.now(),
      status: _statusFrom(json),
    );
  }

  static MessageStatus _statusFrom(Map<String, dynamic> json) {
    if (json['read_at'] != null) return MessageStatus.read;
    if (json['delivered_at'] != null) return MessageStatus.delivered;
    switch (json['status']?.toString().toLowerCase()) {
      case 'read':
        return MessageStatus.read;
      case 'delivered':
        return MessageStatus.delivered;
      default:
        return MessageStatus.sent;
    }
  }

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
        id: id,
        text: text,
        isMine: isMine,
        sentAt: sentAt,
        status: status ?? this.status,
      );
}
