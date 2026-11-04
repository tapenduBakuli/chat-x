import '../../home/model/friend.dart';
import 'chat_message.dart';

/// A 1:1 conversation from POST conversations (`data`). Defensive like the
/// friend models: missing/wrong-typed values fall back to safe defaults.
class Conversation {
  final String id;

  /// The peer (`other_user`), parsed with [FriendUser.fromUserJson].
  final FriendUser otherUser;

  /// `friendship_status` of the peer (e.g. "friends"); '' when absent.
  final String friendshipStatus;

  /// Null for a brand-new conversation.
  final String? lastMessageSnippet;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  const Conversation({
    required this.id,
    required this.otherUser,
    this.friendshipStatus = '',
    this.lastMessageSnippet,
    this.unreadCount = 0,
    this.lastMessageAt,
    this.createdAt,
  });

  /// True when nothing has been sent yet.
  bool get hasNoMessages => lastMessageSnippet == null && lastMessageAt == null;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final other = json['other_user'];
    final otherMap =
        other is Map ? Map<String, dynamic>.from(other) : <String, dynamic>{};
    final snippet = json['last_message_snippet'];
    final unread = json['unread_count'];
    return Conversation(
      id: json['id']?.toString() ?? '',
      otherUser: FriendUser.fromUserJson(otherMap),
      friendshipStatus: otherMap['friendship_status']?.toString() ?? '',
      lastMessageSnippet: snippet?.toString(),
      unreadCount: unread is num
          ? unread.toInt()
          : (unread is String ? int.tryParse(unread) ?? 0 : 0),
      lastMessageAt: _parseDate(json['last_message_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;
}

/// Argument for Routes.CHAT when the conversation comes from the API.
/// (A plain [FriendUser] argument still opens the demo chat.)
class ChatArgs {
  final Conversation conversation;
  const ChatArgs(this.conversation);
}

/// GET conversations?limit=&offset= response. Rows without an id are skipped
/// (they cannot be opened) but still counted in [rawCount], because paging is
/// by raw server rows.
class ConversationListResponse {
  final bool success;
  final String message;
  final List<Conversation> items;
  final int rawCount;
  final int total;
  final int limit;
  final int offset;

  const ConversationListResponse({
    required this.success,
    this.message = '',
    this.items = const <Conversation>[],
    this.rawCount = 0,
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map ? data : const <dynamic, dynamic>{};
    final rawItems = dataMap['items'];
    final parsed = <Conversation>[];
    var rawCount = 0;
    if (rawItems is List) {
      for (final e in rawItems) {
        rawCount++;
        if (e is Map) {
          final c = Conversation.fromJson(Map<String, dynamic>.from(e));
          if (c.id.isNotEmpty) parsed.add(c);
        }
      }
    }
    return ConversationListResponse(
      success: json['success'] is bool ? json['success'] as bool : true,
      message: json['message']?.toString() ?? '',
      items: List<Conversation>.unmodifiable(parsed),
      rawCount: rawCount,
      total: _toInt(dataMap['total']),
      limit: _toInt(dataMap['limit']),
      offset: _toInt(dataMap['offset']),
    );
  }

  static int _toInt(dynamic v) =>
      v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? 0 : 0);
}

/// GET conversations/{id}/messages?limit=&offset= response. [items] keep the
/// SERVER order (newest first); rows without an id are skipped but still
/// counted in [rawCount], because paging is by raw server rows.
class MessageListResponse {
  final bool success;
  final String message;
  final List<ChatMessage> items;
  final int rawCount;
  final int total;
  final int limit;
  final int offset;

  const MessageListResponse({
    required this.success,
    this.message = '',
    this.items = const <ChatMessage>[],
    this.rawCount = 0,
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory MessageListResponse.fromJson(
    Map<String, dynamic> json, {
    required bool Function(Map<String, dynamic> json) isMine,
  }) {
    final data = json['data'];
    final dataMap = data is Map ? data : const <dynamic, dynamic>{};
    final rawItems = dataMap['items'];
    final parsed = <ChatMessage>[];
    var rawCount = 0;
    if (rawItems is List) {
      for (final e in rawItems) {
        rawCount++;
        if (e is Map) {
          final m = ChatMessage.fromApiJson(
            Map<String, dynamic>.from(e),
            isMine: isMine,
          );
          if (m != null) parsed.add(m);
        }
      }
    }
    return MessageListResponse(
      success: json['success'] is bool ? json['success'] as bool : true,
      message: json['message']?.toString() ?? '',
      items: List<ChatMessage>.unmodifiable(parsed),
      rawCount: rawCount,
      total: ConversationListResponse._toInt(dataMap['total']),
      limit: ConversationListResponse._toInt(dataMap['limit']),
      offset: ConversationListResponse._toInt(dataMap['offset']),
    );
  }
}
