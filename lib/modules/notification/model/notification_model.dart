/// Response for GET /notifications?unread_only=&limit=&offset=
///
/// { "success": bool, "message": string|null,
///   "data": { "items": [NotificationItem], "total": int, "limit": int,
///             "offset": int } }
class NotificationListResponse {
  final bool success;
  final String message;
  final List<NotificationItem> items;
  final int total;
  final int limit;
  final int offset;

  const NotificationListResponse({
    required this.success,
    required this.message,
    this.items = const [],
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final Map<String, dynamic> d =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final rawItems = d['items'];
    return NotificationListResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) =>
                  NotificationItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      total: _toInt(d['total']),
      limit: _toInt(d['limit']),
      offset: _toInt(d['offset']),
    );
  }
}

class NotificationItem {
  final String id;
  final String eventType;
  final String title;
  final String body;

  /// Event-specific payload (e.g. { "user_id": "..." } for friend_request).
  final Map<String, dynamic> data;

  /// false = not seen yet (highlighted in the list); true = already seen.
  final bool isRead;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.eventType,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return NotificationItem(
      id: (json['id'] ?? '').toString(),
      eventType: (json['event_type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      data: rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : const <String, dynamic>{},
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        eventType: eventType,
        title: title,
        body: body,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
