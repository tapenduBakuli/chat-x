/// Immutable, dependency-free models for a browse-members profile returned by
/// GET /users (`data.items[]`). Every `fromJson` factory is defensive: missing,
/// null or wrong-typed values fall back to safe defaults (empty string, 0,
/// empty list) so a malformed entry never throws. A `profile: null` member
/// parses to an empty [MemberProfile].
library;

String _str(dynamic v) => v is String ? v : (v?.toString() ?? '');

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// `location` may be a plain string ("Remains Hidden") or an object such as
/// `{city, region|state, country}` / `{name|label}`.
String _location(dynamic v) {
  if (v is String) return v;
  if (v is Map) {
    final named = _str(v['name']).isNotEmpty ? _str(v['name']) : _str(v['label']);
    if (named.isNotEmpty) return named;
    final region = _str(v['region']).isNotEmpty ? v['region'] : v['state'];
    return <String>[_str(v['city']), _str(region), _str(v['country'])]
        .where((e) => e.trim().isNotEmpty)
        .join(', ');
  }
  return '';
}

List<String> _strList(dynamic v) {
  if (v is List) {
    return v.map(_str).where((e) => e.isNotEmpty).toList(growable: false);
  }
  // Tolerate a single string where a list is expected.
  if (v is String && v.isNotEmpty) return <String>[v];
  return const <String>[];
}

/// A single remote photo attached to a member profile.
class MemberPhoto {
  final String id;
  final String url;
  final int position;

  const MemberPhoto({
    required this.id,
    required this.url,
    required this.position,
  });

  factory MemberPhoto.fromJson(Map<String, dynamic> json) {
    return MemberPhoto(
      id: _str(json['id']),
      url: _str(json['url']),
      position: _int(json['position']),
    );
  }
}

/// The nested `profile` object of a member (may be absent → [empty]).
class MemberProfile {
  /// Raw backend gender (mixed vocabulary: "male", "Woman", "Man", "other"…);
  /// '' when null. Use [Member.genderLabel] for display.
  final String gender;

  /// `orientation` list from the API.
  final List<String> orientations;

  /// `about_me`.
  final String bio;

  /// `location` — a plain string (e.g. "Remains Hidden").
  final String location;

  /// Not provided by the API yet; always ''.
  final String city;

  /// Not provided by the API yet; always ''.
  final String region;

  final List<String> interests;

  /// `looking_for`.
  final List<String> lookingFor;

  /// `relationship_preferences`.
  final List<String> relationshipIntents;

  /// Photos ordered ascending by position.
  final List<MemberPhoto> photos;

  /// Profile-level `avatar_url` ('' when null).
  final String avatarUrl;

  /// Detail-only fields (GET /users/{id}); empty when not provided.
  final List<String> corePhysicalIntimate;
  final List<String> explorationKink;
  final List<String> sexualPreferences;
  final String personalSafetyInfo;
  final String hasStdOrSti;

  const MemberProfile({
    required this.gender,
    required this.orientations,
    required this.bio,
    required this.location,
    required this.city,
    required this.region,
    required this.interests,
    required this.lookingFor,
    required this.relationshipIntents,
    required this.photos,
    required this.avatarUrl,
    this.corePhysicalIntimate = const <String>[],
    this.explorationKink = const <String>[],
    this.sexualPreferences = const <String>[],
    this.personalSafetyInfo = '',
    this.hasStdOrSti = '',
  });

  /// Detail values win; list values are kept wherever the detail is empty.
  MemberProfile mergeWith(MemberProfile d) {
    String s(String a, String b) => a.isNotEmpty ? a : b;
    List<T> l<T>(List<T> a, List<T> b) => a.isNotEmpty ? a : b;
    return MemberProfile(
      gender: s(d.gender, gender),
      orientations: l(d.orientations, orientations),
      bio: s(d.bio, bio),
      location: s(d.location, location),
      city: s(d.city, city),
      region: s(d.region, region),
      interests: l(d.interests, interests),
      lookingFor: l(d.lookingFor, lookingFor),
      relationshipIntents: l(d.relationshipIntents, relationshipIntents),
      photos: l(d.photos, photos),
      avatarUrl: s(d.avatarUrl, avatarUrl),
      corePhysicalIntimate: l(d.corePhysicalIntimate, corePhysicalIntimate),
      explorationKink: l(d.explorationKink, explorationKink),
      sexualPreferences: l(d.sexualPreferences, sexualPreferences),
      personalSafetyInfo: s(d.personalSafetyInfo, personalSafetyInfo),
      hasStdOrSti: s(d.hasStdOrSti, hasStdOrSti),
    );
  }

  /// Used when the API returns `profile: null`.
  static const MemberProfile empty = MemberProfile(
    gender: '',
    orientations: <String>[],
    bio: '',
    location: '',
    city: '',
    region: '',
    interests: <String>[],
    lookingFor: <String>[],
    relationshipIntents: <String>[],
    photos: <MemberPhoto>[],
    avatarUrl: '',
  );

  /// Orientation(s) joined for display, e.g. "heterosexual".
  String get orientation => orientations.join(', ');

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];
    final photos = <MemberPhoto>[];
    if (rawPhotos is List) {
      for (final p in rawPhotos) {
        if (p is Map) {
          photos.add(MemberPhoto.fromJson(Map<String, dynamic>.from(p)));
        }
      }
    }
    // Keep photos ordered ascending by position.
    photos.sort((a, b) => a.position.compareTo(b.position));

    return MemberProfile(
      gender: _str(json['gender']),
      orientations: _strList(json['orientation']),
      bio: _str(json['about_me']),
      location: _location(json['location']),
      // city/region are not part of the users API yet.
      city: '',
      region: '',
      interests: _strList(json['interests']),
      lookingFor: _strList(json['looking_for']),
      relationshipIntents: _strList(json['relationship_preferences']),
      photos: List<MemberPhoto>.unmodifiable(photos),
      avatarUrl: _str(json['avatar_url']),
      corePhysicalIntimate: _strList(json['core_physical_intimate']),
      explorationKink: _strList(json['exploration_kink']),
      sexualPreferences: _strList(json['sexual_preferences']),
      personalSafetyInfo: _str(json['personal_safety_info']),
      hasStdOrSti: _str(json['has_std_or_sti']),
    );
  }
}

/// A browsable member: identity fields plus the nested [MemberProfile].
class Member {
  final String id;
  final String displayName;
  final int age;
  final String role;

  /// `friendship_status`, trimmed + lowercased ("none", "request_sent",
  /// "request_received", "friends", …). A missing/null/blank value is treated
  /// as "none" so the member still shows if the API omits the field.
  final String friendshipStatus;

  /// Top-level `avatar_url` ('' when null).
  final String avatarUrl;
  final MemberProfile profile;

  const Member({
    required this.id,
    required this.displayName,
    required this.age,
    this.friendshipStatus = 'none',
    required this.role,
    required this.avatarUrl,
    required this.profile,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'];
    final profile = rawProfile is Map
        ? MemberProfile.fromJson(Map<String, dynamic>.from(rawProfile))
        : MemberProfile.empty;
    final status = _str(json['friendship_status']).trim().toLowerCase();

    return Member(
      id: _str(json['id']),
      displayName: _str(json['display_name']),
      age: _int(json['age']),
      role: _str(json['role']),
      friendshipStatus: status.isEmpty ? 'none' : status,
      avatarUrl: _str(json['avatar_url']),
      profile: profile,
    );
  }

  /// Merges a freshly fetched [detail] over this (list) member: fetched values
  /// win, list values are kept for anything the detail leaves empty.
  Member mergeWith(Member detail) {
    String s(String a, String b) => a.isNotEmpty ? a : b;
    return Member(
      id: s(detail.id, id),
      displayName: s(detail.displayName, displayName),
      age: detail.age > 0 ? detail.age : age,
      role: s(detail.role, role),
      friendshipStatus: detail.friendshipStatus,
      avatarUrl: s(detail.avatarUrl, avatarUrl),
      profile: profile.mergeWith(detail.profile),
    );
  }

  /// True when there is no friendship/request with this member yet — the only
  /// members the browse list shows.
  bool get isFriendshipNone => friendshipStatus == 'none';

  /// True when the API reports this member as blocked. The users API has no
  /// dedicated `is_blocked` field, so a "blocked" friendship_status is the
  /// only server signal; otherwise members start unblocked.
  bool get isBlocked => friendshipStatus == 'blocked';

  /// Non-empty photo URLs ordered by position. Falls back to the profile
  /// avatar, then the top-level avatar; empty when the member has none (the
  /// UI then shows its placeholder).
  List<String> get photoUrls {
    final urls = profile.photos
        .map((p) => p.url)
        .where((u) => u.isNotEmpty)
        .toList(growable: false);
    if (urls.isNotEmpty) return urls;
    if (profile.avatarUrl.isNotEmpty) return <String>[profile.avatarUrl];
    if (avatarUrl.isNotEmpty) return <String>[avatarUrl];
    return const <String>[];
  }

  /// First photo URL (see [photoUrls] fallbacks), or '' when there is none.
  String get firstPhotoUrl {
    final urls = photoUrls;
    return urls.isEmpty ? '' : urls.first;
  }

  /// Display label normalising the backend's mixed gender values:
  /// male/man → "Male", female/woman → "Female", other/non-binary → "Other";
  /// anything else is capitalised as-is; null/'' → ''.
  String get genderLabel {
    final g = profile.gender.trim();
    if (g.isEmpty) return '';
    switch (g.toLowerCase()) {
      case 'male':
      case 'man':
        return 'Male';
      case 'female':
      case 'woman':
        return 'Female';
      case 'other':
      case 'non-binary':
      case 'nonbinary':
      case 'non_binary':
        return 'Other';
      default:
        return g[0].toUpperCase() + g.substring(1);
    }
  }
}

/// Wrapper for GET /users: `{success, message, data: {items, total, limit,
/// offset}}`.
class MemberListResponse {
  final bool success;
  final String message;
  final List<Member> items;
  final int total;
  final int limit;
  final int offset;

  const MemberListResponse({
    required this.success,
    this.message = '',
    this.items = const <Member>[],
    this.total = 0,
    this.limit = 0,
    this.offset = 0,
  });

  factory MemberListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = <Member>[];
    int total = 0, limit = 0, offset = 0;
    if (data is Map) {
      final rawItems = data['items'];
      if (rawItems is List) {
        for (final i in rawItems) {
          if (i is Map) items.add(Member.fromJson(Map<String, dynamic>.from(i)));
        }
      }
      total = _int(data['total']);
      limit = _int(data['limit']);
      offset = _int(data['offset']);
    }
    return MemberListResponse(
      // Treat a missing `success` on a 200 as success.
      success: json['success'] is bool ? json['success'] as bool : true,
      message: _str(json['message']),
      items: List<Member>.unmodifiable(items),
      total: total,
      limit: limit,
      offset: offset,
    );
  }
}

/// Realtime user availability returned by GET /users/{user_id}/availability.
class UserAvailability {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final bool canReceiveMessages;

  const UserAvailability({
    required this.userId,
    required this.isOnline,
    this.lastSeenAt,
    this.canReceiveMessages = true,
  });

  factory UserAvailability.fromJson(Map<String, dynamic> json) {
    final data =
        json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return UserAvailability(
      userId: _str(data['user_id']),
      isOnline: data['is_online'] is bool ? data['is_online'] as bool : false,
      lastSeenAt: data['last_seen_at'] is String
          ? DateTime.tryParse(data['last_seen_at'] as String)?.toLocal()
          : null,
      canReceiveMessages: data['can_receive_messages'] is bool
          ? data['can_receive_messages'] as bool
          : true,
    );
  }
}
