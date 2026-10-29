/// Response for PUT /users/me (update my profile) and GET /users/me (get my
/// account — see [MyProfileResponse]); both share the same `data` shape.
///
/// {
///   "success": bool,
///   "message": string,
///   "data": {
///     "id", "email", "display_name", "avatar_url", "date_of_birth",
///     "country", "promo_code", "role", "is_invisible", "has_payment_method",
///     "trial_ends_at", "created_at",
///     "profile": { "gender", "orientation": [..], "location": {..}, ... }
///   }
/// }
///
/// Parsing is defensive: missing strings default to '', missing lists to [],
/// nested objects are only parsed when they are maps.
class UpdateProfileResponseModel {
  final bool success;
  final String message;
  final UpdateProfileUser? data;

  const UpdateProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UpdateProfileResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: data is Map
          ? UpdateProfileUser.fromJson(Map<String, dynamic>.from(data))
          : null,
    );
  }
}

/// The updated user returned in `data`.
class UpdateProfileUser {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String dateOfBirth;
  final String country;
  final String promoCode;
  final String role;
  final bool isInvisible;
  final bool hasPaymentMethod;
  final String trialEndsAt;
  final String createdAt;
  final UpdateProfileDetails? profile;

  const UpdateProfileUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.dateOfBirth,
    required this.country,
    required this.promoCode,
    required this.role,
    required this.isInvisible,
    required this.hasPaymentMethod,
    required this.trialEndsAt,
    required this.createdAt,
    this.profile,
  });

  factory UpdateProfileUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return UpdateProfileUser(
      id: _str(json['id']),
      email: _str(json['email']),
      displayName: _str(json['display_name']),
      avatarUrl: _str(json['avatar_url']),
      dateOfBirth: _str(json['date_of_birth']),
      country: _str(json['country']),
      promoCode: _str(json['promo_code']),
      role: _str(json['role']),
      isInvisible: json['is_invisible'] == true,
      hasPaymentMethod: json['has_payment_method'] == true,
      trialEndsAt: _str(json['trial_ends_at']),
      createdAt: _str(json['created_at']),
      profile: profile is Map
          ? UpdateProfileDetails.fromJson(Map<String, dynamic>.from(profile))
          : null,
    );
  }
}

/// The nested `profile` object.
class UpdateProfileDetails {
  final String gender;
  final List<String> orientation;
  final UpdateProfileLocation? location;
  final List<String> lookingFor;
  final String aboutMe;
  final List<String> relationshipPreferences;
  final List<String> corePhysicalIntimate;
  final List<String> explorationKink;
  final List<String> sexualPreferences;
  final List<String> interestAndPassion;
  final String personalSafetyInfo;
  final String hasStdOrSti;
  final String preferenceVisibilityMode;
  final String avatarUrl;
  final List<UpdateProfilePhoto> photos;
  final bool isComplete;

  const UpdateProfileDetails({
    required this.gender,
    required this.orientation,
    this.location,
    required this.lookingFor,
    required this.aboutMe,
    required this.relationshipPreferences,
    required this.corePhysicalIntimate,
    required this.explorationKink,
    required this.sexualPreferences,
    required this.interestAndPassion,
    required this.personalSafetyInfo,
    required this.hasStdOrSti,
    required this.preferenceVisibilityMode,
    required this.avatarUrl,
    required this.photos,
    required this.isComplete,
  });

  factory UpdateProfileDetails.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    return UpdateProfileDetails(
      gender: _str(json['gender']),
      orientation: _strList(json['orientation']),
      location: location is Map
          ? UpdateProfileLocation.fromJson(Map<String, dynamic>.from(location))
          : null,
      lookingFor: _strList(json['looking_for']),
      aboutMe: _str(json['about_me']),
      relationshipPreferences: _strList(json['relationship_preferences']),
      corePhysicalIntimate: _strList(json['core_physical_intimate']),
      explorationKink: _strList(json['exploration_kink']),
      sexualPreferences: _strList(json['sexual_preferences']),
      interestAndPassion: _strList(json['interest_and_passion']),
      personalSafetyInfo: _str(json['personal_safety_info']),
      hasStdOrSti: _str(json['has_std_or_sti']),
      preferenceVisibilityMode: _str(json['preference_visibility_mode']),
      avatarUrl: _str(json['avatar_url']),
      photos: _photoList(json['photos']),
      isComplete: json['is_complete'] == true,
    );
  }
}

/// The nested `profile.location` object.
class UpdateProfileLocation {
  final double? latitude;
  final double? longitude;
  final String city;
  final String region;

  const UpdateProfileLocation({
    this.latitude,
    this.longitude,
    required this.city,
    required this.region,
  });

  factory UpdateProfileLocation.fromJson(Map<String, dynamic> json) {
    return UpdateProfileLocation(
      latitude: _num(json['latitude']),
      longitude: _num(json['longitude']),
      city: _str(json['city']),
      region: _str(json['region']),
    );
  }
}

/// One entry of `profile.photos`: `{ "id", "url", "position" }`.
class UpdateProfilePhoto {
  final String id;
  final String url;
  final int position;

  const UpdateProfilePhoto({
    required this.id,
    required this.url,
    required this.position,
  });

  factory UpdateProfilePhoto.fromJson(Map<String, dynamic> json) {
    final pos = json['position'];
    return UpdateProfilePhoto(
      id: _str(json['id']),
      url: _str(json['url']),
      position: pos is num ? pos.toInt() : int.tryParse(_str(pos)) ?? 0,
    );
  }
}

/// GET /users/me returns the same envelope/shape as the PUT response.
typedef MyProfileResponse = UpdateProfileResponseModel;

String _str(dynamic v) => (v ?? '').toString();

/// Parses `photos` defensively: object entries `{id,url,position}` are the
/// documented shape; bare string entries (URL only) are tolerated with their
/// list index as position. Anything else is skipped.
List<UpdateProfilePhoto> _photoList(dynamic v) {
  if (v is! List) return <UpdateProfilePhoto>[];
  final result = <UpdateProfilePhoto>[];
  for (var i = 0; i < v.length; i++) {
    final e = v[i];
    if (e is Map) {
      result.add(UpdateProfilePhoto.fromJson(Map<String, dynamic>.from(e)));
    } else if (e is String && e.isNotEmpty) {
      result.add(UpdateProfilePhoto(id: '', url: e, position: i));
    }
  }
  return result;
}

double? _num(dynamic v) => v is num ? v.toDouble() : null;

List<String> _strList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : <String>[];
