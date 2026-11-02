/// Models for the Friends tab. [FriendUser] is the shared row shape; all three
/// sections are API-backed: incoming requests (GET friends/requests →
/// [IncomingFriendRequest]), My Friends (GET friends → [Friendship]) and
/// Sent Requests (GET friends/requests/sent → [SentFriendRequest]).
/// Every `fromJson` is defensive: missing/null/wrong-typed values fall back to
/// safe defaults so a malformed entry never throws.
library;

String _str(dynamic v) => v is String ? v : (v?.toString() ?? '');

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

DateTime? _date(dynamic v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// `avatar_url` → `profile.avatar_url` → url of the `profile.photos` entry
/// with the lowest `position` → '' (initials placeholder).
String _resolveAvatar(Map<String, dynamic> user) {
  final top = _str(user['avatar_url']).trim();
  if (top.isNotEmpty) return top;
  final profile = _map(user['profile']);
  final fromProfile = _str(profile['avatar_url']).trim();
  if (fromProfile.isNotEmpty) return fromProfile;
  final photos = profile['photos'];
  if (photos is! List) return '';
  String best = '';
  num? bestPos;
  for (final p in photos) {
    if (p is! Map) continue;
    final url = _str(p['url']).trim();
    if (url.isEmpty) continue;
    final raw = p['position'];
    final num? pos = raw is num
        ? raw
        : (raw is String ? num.tryParse(raw) : null);
    if (best.isEmpty) {
      best = url;
      bestPos = pos;
      continue;
    }
    // Missing/invalid positions sort last; ties keep the earlier entry.
    if (pos != null && (bestPos == null || pos < bestPos)) {
      best = url;
      bestPos = pos;
    }
  }
  return best;
}

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// e.g. "Nov 2, 2026".
String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// A user shown in the Friends tab — a pending friend request (incoming or
/// sent) or an accepted friend.
class FriendUser {
  final String id;
  final String displayName;
  final int age;
  final String avatarUrl;

  /// Short line under the name (e.g. orientation / "Online now").
  final String subtitle;

  /// For requests: when it was sent. For friends: when they became friends.
  final DateTime? since;

  final bool isOnline;

  const FriendUser({
    required this.id,
    required this.displayName,
    this.age = 0,
    this.avatarUrl = '',
    this.subtitle = '',
    this.since,
    this.isOnline = false,
  });

  /// Builds from a users-API style object (`id`, `display_name`, `age`,
  /// `avatar_url`, optional `profile`). Avatar falls back `avatar_url` →
  /// `profile.avatar_url` → lowest-position `profile.photos` url → ''
  /// (initials placeholder); URLs are used verbatim, same as [Member].
  /// Null age → 0 (age omitted). `friendship_status` is intentionally ignored.
  factory FriendUser.fromUserJson(
    Map<String, dynamic> json, {
    String subtitle = '',
    DateTime? since,
  }) {
    return FriendUser(
      id: _str(json['id']),
      displayName: _str(json['display_name']),
      age: _int(json['age']),
      avatarUrl: _resolveAvatar(json),
      subtitle: subtitle,
      since: since,
    );
  }
}

/// One item of GET friends/requests/sent: the request id (used by the cancel
/// DELETE) and the addressee as a [FriendUser].
class SentFriendRequest {
  /// `items[].id` — path id for DELETE friends/requests/sent/{id}.
  final String requestId;

  /// The addressee; `user.id` is their user id (used for Browse sync).
  final FriendUser user;

  final DateTime? createdAt;

  const SentFriendRequest({
    required this.requestId,
    required this.user,
    this.createdAt,
  });

  factory SentFriendRequest.fromJson(Map<String, dynamic> json) {
    final createdAt = _date(json['created_at']);
    final addressee = _map(json['addressee']);
    return SentFriendRequest(
      requestId: _str(json['id']),
      user: FriendUser.fromUserJson(
        addressee,
        subtitle: 'Request pending',
        since: createdAt,
      ),
      createdAt: createdAt,
    );
  }
}

/// Wrapper for GET friends/requests/sent: `{success, message, data: {items,
/// total, limit, offset}}`.
class SentFriendRequestListResponse {
  final bool success;
  final String message;
  final List<SentFriendRequest> items;
  final int total;
  final int limit;
  final int offset;

  const SentFriendRequestListResponse({
    required this.success,
    this.message = '',
    this.items = const <SentFriendRequest>[],
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory SentFriendRequestListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = <SentFriendRequest>[];
    int total = 0, limit = 0, offset = 0;
    if (data is Map) {
      final rawItems = data['items'];
      if (rawItems is List) {
        for (final i in rawItems) {
          if (i is! Map) continue;
          final req =
              SentFriendRequest.fromJson(Map<String, dynamic>.from(i));
          // Without a request id the row can't be cancelled — skip it.
          if (req.requestId.isNotEmpty) items.add(req);
        }
      }
      total = _int(data['total']);
      limit = _int(data['limit']);
      offset = _int(data['offset']);
    }
    return SentFriendRequestListResponse(
      // Treat a missing `success` on a 200 as success.
      success: json['success'] is bool ? json['success'] as bool : true,
      message: _str(json['message']),
      items: List<SentFriendRequest>.unmodifiable(items),
      total: total,
      limit: limit,
      offset: offset,
    );
  }
}

/// One item of GET friends/requests: the request id (used by the accept
/// POST) and the requester as a [FriendUser].
class IncomingFriendRequest {
  /// `items[].id` — path id for POST friends/requests/{id}/accept.
  final String requestId;

  /// The requester; `user.id` is their user id.
  final FriendUser user;

  final DateTime? createdAt;

  const IncomingFriendRequest({
    required this.requestId,
    required this.user,
    this.createdAt,
  });

  factory IncomingFriendRequest.fromJson(Map<String, dynamic> json) {
    final createdAt = _date(json['created_at']);
    final requester = _map(json['requester']);
    return IncomingFriendRequest(
      requestId: _str(json['id']),
      user: FriendUser.fromUserJson(
        requester,
        subtitle: 'Wants to connect with you',
        since: createdAt,
      ),
      createdAt: createdAt,
    );
  }
}

/// Wrapper for GET friends/requests: `{success, message, data: {items,
/// total, limit, offset}}`.
class IncomingFriendRequestListResponse {
  final bool success;
  final String message;
  final List<IncomingFriendRequest> items;
  final int total;
  final int limit;
  final int offset;

  const IncomingFriendRequestListResponse({
    required this.success,
    this.message = '',
    this.items = const <IncomingFriendRequest>[],
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory IncomingFriendRequestListResponse.fromJson(
      Map<String, dynamic> json) {
    final data = json['data'];
    final items = <IncomingFriendRequest>[];
    int total = 0, limit = 0, offset = 0;
    if (data is Map) {
      final rawItems = data['items'];
      if (rawItems is List) {
        for (final i in rawItems) {
          if (i is! Map) continue;
          final req =
              IncomingFriendRequest.fromJson(Map<String, dynamic>.from(i));
          // Without a request id the row can't be accepted — skip it.
          if (req.requestId.isNotEmpty) items.add(req);
        }
      }
      total = _int(data['total']);
      limit = _int(data['limit']);
      offset = _int(data['offset']);
    }
    return IncomingFriendRequestListResponse(
      // Treat a missing `success` on a 200 as success.
      success: json['success'] is bool ? json['success'] as bool : true,
      message: _str(json['message']),
      items: List<IncomingFriendRequest>.unmodifiable(items),
      total: total,
      limit: limit,
      offset: offset,
    );
  }
}

/// One item of GET friends: the friendship id and the friend as a
/// [FriendUser].
class Friendship {
  /// `items[].id` (friendship id). NOT used by remove-friend —
  /// DELETE friends/{id} takes the friend's `user.id`.
  final String friendshipId;

  /// The friend; `user.id` is their user id (passed to the chat screen).
  final FriendUser user;

  final DateTime? friendsSince;

  const Friendship({
    required this.friendshipId,
    required this.user,
    this.friendsSince,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    final friendsSince = _date(json['friends_since']);
    final u = _map(json['user']);
    // Always show the friendship date so every row is consistent
    // (location is often a placeholder like "Remains Hidden").
    final String subtitle = friendsSince != null
        ? 'Friends since ${_formatDate(friendsSince)}'
        : 'Friend';
    return Friendship(
      friendshipId: _str(json['id']),
      user: FriendUser.fromUserJson(u, subtitle: subtitle, since: friendsSince),
      friendsSince: friendsSince,
    );
  }
}

/// Wrapper for GET friends: `{success, message, data: {items, total, limit,
/// offset}}`.
class FriendshipListResponse {
  final bool success;
  final String message;
  final List<Friendship> items;
  final int total;
  final int limit;
  final int offset;

  const FriendshipListResponse({
    required this.success,
    this.message = '',
    this.items = const <Friendship>[],
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory FriendshipListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = <Friendship>[];
    int total = 0, limit = 0, offset = 0;
    if (data is Map) {
      final rawItems = data['items'];
      if (rawItems is List) {
        for (final i in rawItems) {
          if (i is! Map) continue;
          final f = Friendship.fromJson(Map<String, dynamic>.from(i));
          // Needs a friendship id (remove) and a user id (chat) — skip if not.
          if (f.friendshipId.isNotEmpty && f.user.id.isNotEmpty) items.add(f);
        }
      }
      total = _int(data['total']);
      limit = _int(data['limit']);
      offset = _int(data['offset']);
    }
    return FriendshipListResponse(
      // Treat a missing `success` on a 200 as success.
      success: json['success'] is bool ? json['success'] as bool : true,
      message: _str(json['message']),
      items: List<Friendship>.unmodifiable(items),
      total: total,
      limit: limit,
      offset: offset,
    );
  }
}

/// One item of GET users/blocked: the blocked member as a [FriendUser]
/// (`blocked_user.id` is the user id passed to DELETE users/{id}/block).
class BlockedUser {
  final FriendUser user;

  /// Optional reason given when blocking ('' when none).
  final String reason;

  final DateTime? blockedAt;

  const BlockedUser({
    required this.user,
    this.reason = '',
    this.blockedAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    final blockedAt = _date(json['blocked_at']);
    final u = _map(json['blocked_user']);
    final String subtitle =
        blockedAt != null ? 'Blocked ${_formatDate(blockedAt)}' : 'Blocked';
    return BlockedUser(
      user: FriendUser.fromUserJson(u, subtitle: subtitle, since: blockedAt),
      reason: _str(json['reason']),
      blockedAt: blockedAt,
    );
  }
}

/// Wrapper for GET users/blocked: `{success, message, data: {items, total,
/// limit, offset}}`.
class BlockedUserListResponse {
  final bool success;
  final String message;
  final List<BlockedUser> items;
  final int total;
  final int limit;
  final int offset;

  const BlockedUserListResponse({
    required this.success,
    this.message = '',
    this.items = const <BlockedUser>[],
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory BlockedUserListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = <BlockedUser>[];
    int total = 0, limit = 0, offset = 0;
    if (data is Map) {
      final rawItems = data['items'];
      if (rawItems is List) {
        for (final i in rawItems) {
          if (i is! Map) continue;
          final b = BlockedUser.fromJson(Map<String, dynamic>.from(i));
          // Without a user id the row can't be unblocked — skip it.
          if (b.user.id.isNotEmpty) items.add(b);
        }
      }
      total = _int(data['total']);
      limit = _int(data['limit']);
      offset = _int(data['offset']);
    }
    return BlockedUserListResponse(
      // Treat a missing `success` on a 200 as success.
      success: json['success'] is bool ? json['success'] as bool : true,
      message: _str(json['message']),
      items: List<BlockedUser>.unmodifiable(items),
      total: total,
      limit: limit,
      offset: offset,
    );
  }
}
