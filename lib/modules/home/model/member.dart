/// Immutable, dependency-free models for a browse-members profile loaded from
/// the bundled `assets/mock_profile_data.json`. Every `fromJson` factory is
/// defensive: missing or wrong-typed values fall back to safe defaults
/// (empty string, 0, empty list, false) so a malformed entry never throws.

String _str(dynamic v) => v is String ? v : (v?.toString() ?? '');

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

bool _bool(dynamic v) => v is bool ? v : false;

List<String> _strList(dynamic v) {
  if (v is List) {
    return v.map(_str).where((e) => e.isNotEmpty).toList(growable: false);
  }
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

/// The nested `profile` object of a member.
class MemberProfile {
  final String gender;
  final String orientation;
  final String bio;
  final String location;
  final String city;
  final String region;
  final List<String> interests;
  final List<String> relationshipIntents;
  final List<String> sexualPreferences;
  final List<MemberPhoto> photos;
  final bool isComplete;

  const MemberProfile({
    required this.gender,
    required this.orientation,
    required this.bio,
    required this.location,
    required this.city,
    required this.region,
    required this.interests,
    required this.relationshipIntents,
    required this.sexualPreferences,
    required this.photos,
    required this.isComplete,
  });

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
      orientation: _str(json['orientation']),
      bio: _str(json['bio']),
      location: _str(json['location']),
      city: _str(json['city']),
      region: _str(json['region']),
      interests: _strList(json['interests']),
      relationshipIntents: _strList(json['relationship_intents']),
      sexualPreferences: _strList(json['sexual_preferences']),
      photos: List<MemberPhoto>.unmodifiable(photos),
      isComplete: _bool(json['is_complete']),
    );
  }
}

/// A browsable member: identity fields plus the nested [MemberProfile].
class Member {
  final String id;
  final String displayName;
  final int age;
  final String role;
  final MemberProfile profile;

  const Member({
    required this.id,
    required this.displayName,
    required this.age,
    required this.role,
    required this.profile,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'];
    final profile = rawProfile is Map
        ? MemberProfile.fromJson(Map<String, dynamic>.from(rawProfile))
        : MemberProfile.fromJson(const <String, dynamic>{});

    return Member(
      id: _str(json['id']),
      displayName: _str(json['display_name']),
      age: _int(json['age']),
      role: _str(json['role']),
      profile: profile,
    );
  }

  /// URL of the first photo (by position), or '' when there are none.
  String get firstPhotoUrl =>
      profile.photos.isEmpty ? '' : profile.photos.first.url;

  /// Non-empty photo URLs ordered by position.
  List<String> get photoUrls => profile.photos
      .map((p) => p.url)
      .where((u) => u.isNotEmpty)
      .toList(growable: false);

  /// Capitalized gender label (e.g. "Female"); '' stays ''.
  String get genderLabel {
    final g = profile.gender;
    if (g.isEmpty) return '';
    return g[0].toUpperCase() + g.substring(1);
  }
}
