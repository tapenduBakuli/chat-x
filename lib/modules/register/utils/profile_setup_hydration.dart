/// Pure helpers that map GET /users/me values onto the Profile Setup option
/// lists / picker formats. Used only by the Edit Profile hydration.
class ProfileSetupHydration {
  const ProfileSetupHydration._();

  // Canonical options (same as the Profile Setup / Edit Profile screens).
  static const List<String> genders = ['Woman', 'Man', 'Non-binary'];
  static const List<String> orientations = [
    'Straight',
    'Bisexual',
    'Gay / Lesbian',
    'Pansexual',
    'Open-minded',
  ];
  static const List<String> lookingFor = [
    'Intimate connection',
    'Casual dating',
    'Discreet exploration',
    'Regular meetups',
    'Deep friendship',
  ];

  static const Map<String, String> _genderAliases = {
    'male': 'Man',
    'female': 'Woman',
    'nonbinary': 'Non-binary',
    'non binary': 'Non-binary',
    'non-binary': 'Non-binary',
  };

  static const Map<String, String> _orientationAliases = {
    'gay': 'Gay / Lesbian',
    'lesbian': 'Gay / Lesbian',
    'gay/lesbian': 'Gay / Lesbian',
    'heterosexual': 'Straight',
    'open minded': 'Open-minded',
    'openminded': 'Open-minded',
  };

  /// Case-insensitive exact match against [options]; null when unknown.
  static String? matchOption(String value, List<String> options) {
    final String v = value.trim().toLowerCase();
    if (v.isEmpty) return null;
    for (final String o in options) {
      if (o.toLowerCase() == v) return o;
    }
    return null;
  }

  static String? matchGender(String value) =>
      matchOption(value, genders) ??
      _genderAliases[value.trim().toLowerCase()];

  /// First server orientation that maps onto a canonical option.
  static String? matchOrientation(List<String> values) {
    for (final String v in values) {
      final String? m = matchOption(v, orientations) ??
          _orientationAliases[v.trim().toLowerCase()];
      if (m != null) return m;
    }
    return null;
  }

  static List<String> matchLookingFor(List<String> values) {
    final List<String> out = <String>[];
    for (final String v in values) {
      final String? m = matchOption(v, lookingFor);
      if (m != null && !out.contains(m)) out.add(m);
    }
    return out;
  }

  /// Parses "YYYY-MM-DD" into the int parts the DOB dropdowns use
  /// (day 1-31, month 1-12, year). Null when unparseable.
  static ({int year, int month, int day})? parseDob(String dob) {
    final Match? m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(dob.trim());
    if (m == null) return null;
    final int year = int.parse(m.group(1)!);
    final int month = int.parse(m.group(2)!);
    final int day = int.parse(m.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return (year: year, month: month, day: day);
  }

  /// The [cities] entry (e.g. "Ghent / Gent (9000)") whose name matches the
  /// server city (e.g. "Ghent"), case-insensitively; null when none matches.
  static String? matchCity(String city, List<String> cities) {
    final String c = city.trim().toLowerCase();
    if (c.isEmpty) return null;
    for (final String entry in cities) {
      if (entry.toLowerCase() == c) return entry;
      final String names = entry.replaceAll(RegExp(r'\s*\(\d+\)\s*$'), '');
      for (final String part in names.split('/')) {
        if (part.trim().toLowerCase() == c) return entry;
      }
    }
    return null;
  }
}
