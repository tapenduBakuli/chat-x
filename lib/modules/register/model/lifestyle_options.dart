/// Lifestyle profile fields (has children, relationship status, works, own
/// house, car): shared option lists, API keys, the send flag and the tolerant
/// parsers / API converters.
///
/// Backend contract (UserUpdate in /openapi.json, PUT /users/me; same keys in
/// GET /users/me `profile`):
///   has_children, works, own_house, car : bool | null
///   relation_status : "single" | "married" | "divorced" | null  (enum,
///                     lowercase; any other value is rejected)
const bool kSendLifestyleFields = true;

class LifestyleOptions {
  const LifestyleOptions._();

  static const List<String> yesNo = ['Yes', 'No'];
  static const List<String> relationshipStatus = [
    'Single',
    'Married',
    'Divorced',
  ];

  static const String keyHasChildren = 'has_children';
  static const String keyRelationshipStatus = 'relation_status';
  static const String keyWorks = 'works';
  static const String keyOwnHouse = 'own_house';
  static const String keyHasCar = 'car';

  /// Older placeholder keys, still read as a fallback when parsing.
  static const String legacyKeyRelationshipStatus = 'relationship_status';
  static const String legacyKeyHasCar = 'has_car';

  /// Tolerant parse of a Yes/No value: bool, or 'yes'/'no'/'true'/'false'
  /// (any case). Returns 'Yes' / 'No', or '' when absent/unknown.
  static String parseYesNo(dynamic v) {
    if (v is bool) return v ? 'Yes' : 'No';
    final String s = (v ?? '').toString().trim().toLowerCase();
    if (s == 'yes' || s == 'true') return 'Yes';
    if (s == 'no' || s == 'false') return 'No';
    return '';
  }

  /// Case-insensitive match to Single / Married / Divorced; '' otherwise.
  static String parseRelationshipStatus(dynamic v) {
    final String s = (v ?? '').toString().trim().toLowerCase();
    for (final String o in relationshipStatus) {
      if (o.toLowerCase() == s) return o;
    }
    return '';
  }

  /// Display label → API value for [key]: bool for the yes/no fields,
  /// lowercase enum for relation_status. null when the label is empty or not
  /// a valid option (the key is then omitted, never sent invalid).
  static Object? toApiValue(String key, String label) {
    final String l = label.trim();
    if (l.isEmpty) return null;
    if (key == keyRelationshipStatus) {
      final String match = parseRelationshipStatus(l);
      return match.isEmpty ? null : match.toLowerCase();
    }
    final String yn = parseYesNo(l);
    if (yn.isEmpty) return null;
    return yn == 'Yes';
  }

  /// Payload entries for the set values, already converted to the API format
  /// ({has_children: true, relation_status: 'single', ...}). Unset omitted.
  static Map<String, Object> payloadEntries(Map<String, String> values) => {
        for (final MapEntry<String, String> e in values.entries)
          if (toApiValue(e.key, e.value) case final Object v) e.key: v,
      };
}
