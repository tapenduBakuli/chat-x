import '../model/update_profile_response_model.dart';

/// Immutable copy of the server values loaded by GET /users/me when Edit
/// Profile opens. Used to build the PUT /users/me payload so that:
/// - display_name, gender and orientation (not editable on Edit Profile) are
///   always the original server values, whatever the UI state is;
/// - single-selects the user left empty fall back to the original value;
/// - list values the UI cannot show (not a known option) are never dropped.
class EditProfileOriginal {
  final String displayName;
  final String gender;
  final List<String> orientation;
  final bool isInvisible;
  final String dateOfBirth;
  final String country;

  /// Raw server location ({latitude, longitude, city, region}), or null.
  final Map<String, dynamic>? location;

  /// The city dropdown value selected right after hydration ('' = none).
  final String hydratedCity;

  final List<String> lookingFor;
  final List<String> relationshipPreferences;
  final List<String> corePhysicalIntimate;
  final List<String> explorationKink;
  final List<String> interestAndPassion;
  final String personalSafetyInfo;
  final String hasStdOrSti;
  final String preferenceVisibilityMode;

  const EditProfileOriginal({
    required this.displayName,
    required this.gender,
    required this.orientation,
    required this.isInvisible,
    required this.dateOfBirth,
    required this.country,
    required this.location,
    required this.hydratedCity,
    required this.lookingFor,
    required this.relationshipPreferences,
    required this.corePhysicalIntimate,
    required this.explorationKink,
    required this.interestAndPassion,
    required this.personalSafetyInfo,
    required this.hasStdOrSti,
    required this.preferenceVisibilityMode,
  });

  factory EditProfileOriginal.fromUser(
    UpdateProfileUser u, {
    required String hydratedCity,
  }) {
    final UpdateProfileDetails? p = u.profile;
    final UpdateProfileLocation? loc = p?.location;
    Map<String, dynamic>? location;
    if (loc != null && (loc.city.isNotEmpty || loc.region.isNotEmpty)) {
      location = <String, dynamic>{
        'latitude': ?loc.latitude,
        'longitude': ?loc.longitude,
        'city': loc.city,
        'region': loc.region,
      };
    }
    return EditProfileOriginal(
      displayName: u.displayName.trim(),
      gender: (p?.gender ?? '').trim(),
      orientation: List<String>.unmodifiable(p?.orientation ?? const []),
      isInvisible: u.isInvisible,
      dateOfBirth: u.dateOfBirth.length >= 10
          ? u.dateOfBirth.substring(0, 10)
          : u.dateOfBirth,
      country: u.country,
      location: location,
      hydratedCity: hydratedCity,
      lookingFor: List<String>.unmodifiable(p?.lookingFor ?? const []),
      relationshipPreferences:
          List<String>.unmodifiable(p?.relationshipPreferences ?? const []),
      corePhysicalIntimate:
          List<String>.unmodifiable(p?.corePhysicalIntimate ?? const []),
      explorationKink:
          List<String>.unmodifiable(p?.explorationKink ?? const []),
      interestAndPassion:
          List<String>.unmodifiable(p?.interestAndPassion ?? const []),
      personalSafetyInfo: p?.personalSafetyInfo ?? '',
      hasStdOrSti: p?.hasStdOrSti ?? '',
      preferenceVisibilityMode: p?.preferenceVisibilityMode ?? '',
    );
  }
}

/// Pure builder for the Edit Profile PUT /users/me payload.
class EditProfilePayload {
  const EditProfilePayload._();

  /// The user's current [selected] options, plus any [original] server values
  /// that are not one of the known [options] (the UI cannot show or deselect
  /// those, so dropping them would silently erase data). Known options follow
  /// [selected] exactly: deselected ones are removed, new ones are added.
  static List<String> withUnmatched({
    required List<String> selected,
    required List<String> original,
    required List<String> options,
  }) {
    final List<String> lowerOptions =
        options.map((o) => o.toLowerCase()).toList();
    final List<String> out = List<String>.of(selected);
    for (final String v in original) {
      if (!lowerOptions.contains(v.trim().toLowerCase()) && !out.contains(v)) {
        out.add(v);
      }
    }
    return out;
  }

  /// Current value, else the original server value, else null (key omitted).
  static String? _singleSelect(String current, String original) {
    if (current.trim().isNotEmpty) return current;
    if (original.trim().isNotEmpty) return original;
    return null;
  }

  /// [newLocation] is the user's newly chosen city payload (null when the
  /// city dropdown is unchanged); the original server location is kept then.
  static Map<String, dynamic> build({
    required EditProfileOriginal original,
    required String dateOfBirth,
    required String country,
    required String aboutMe,
    required Map<String, dynamic>? newLocation,
    required List<String> lookingFor,
    required List<String> relationshipPreferences,
    required List<String> corePhysicalIntimate,
    required List<String> explorationKink,
    required List<String> interestAndPassion,
    required String personalSafetyInfo,
    required String hasStdOrSti,
    required String preferenceVisibilityMode,
  }) {
    final Map<String, dynamic>? location = newLocation ?? original.location;
    final String? safety =
        _singleSelect(personalSafetyInfo, original.personalSafetyInfo);
    final String? sti = _singleSelect(hasStdOrSti, original.hasStdOrSti);
    final String? visibility = _singleSelect(
        preferenceVisibilityMode, original.preferenceVisibilityMode);

    return <String, dynamic>{
      // Not editable here: always the original server values, never empty.
      if (original.displayName.isNotEmpty) 'display_name': original.displayName,
      'is_invisible': original.isInvisible,
      if (dateOfBirth.isNotEmpty) 'date_of_birth': dateOfBirth,
      if (country.isNotEmpty) 'country': country,
      if (original.gender.isNotEmpty) 'gender': original.gender,
      if (original.orientation.isNotEmpty)
        'orientation': List<String>.of(original.orientation),
      'about_me': aboutMe,
      'location': ?location,
      'looking_for': List<String>.of(lookingFor),
      'relationship_preferences': List<String>.of(relationshipPreferences),
      'core_physical_intimate': List<String>.of(corePhysicalIntimate),
      'exploration_kink': List<String>.of(explorationKink),
      'interest_and_passion': List<String>.of(interestAndPassion),
      'personal_and_safety_information': ?safety,
      'has_std_or_sti': ?sti,
      'preference_visibility_mode': ?visibility,
      // `photos` deliberately omitted (gallery has its own endpoints).
    };
  }
}
