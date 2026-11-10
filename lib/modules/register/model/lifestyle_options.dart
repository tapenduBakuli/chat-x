/// Lifestyle profile fields (has children, relationship status, works, own
/// house, car): shared option lists, API key placeholders, the send flag and
/// the single tolerant parser. UI + state only until the backend supports them.
// TODO(api): enable once backend adds these keys to UserUpdate (additionalProperties:false today)
const bool kSendLifestyleFields = false;

class LifestyleOptions {
  const LifestyleOptions._();

  static const List<String> yesNo = ['Yes', 'No'];
  static const List<String> relationshipStatus = [
    'Single',
    'Married',
    'Divorced',
  ];

  // TODO(api): confirm key names/values with backend
  static const String keyHasChildren = 'has_children';
  static const String keyRelationshipStatus = 'relationship_status';
  static const String keyWorks = 'works';
  static const String keyOwnHouse = 'own_house';
  static const String keyHasCar = 'has_car';

  /// Tolerant parse of a Yes/No value: bool, or 'yes'/'no'/'true'/'false'
  /// (any case). Returns 'Yes' / 'No', or '' when absent/unknown.
  // TODO(api): confirm key names/values with backend
  static String parseYesNo(dynamic v) {
    if (v is bool) return v ? 'Yes' : 'No';
    final String s = (v ?? '').toString().trim().toLowerCase();
    if (s == 'yes' || s == 'true') return 'Yes';
    if (s == 'no' || s == 'false') return 'No';
    return '';
  }

  /// Case-insensitive match to Single / Married / Divorced; '' otherwise.
  // TODO(api): confirm key names/values with backend
  static String parseRelationshipStatus(dynamic v) {
    final String s = (v ?? '').toString().trim().toLowerCase();
    for (final String o in relationshipStatus) {
      if (o.toLowerCase() == s) return o;
    }
    return '';
  }

  /// Payload entries for non-empty values. Value format: the display label
  /// string ('Yes'/'No'/'Single'/...). Only used behind [kSendLifestyleFields].
  // TODO(api): confirm key names/values with backend
  static Map<String, String> payloadEntries(Map<String, String> values) => {
        for (final MapEntry<String, String> e in values.entries)
          if (e.value.trim().isNotEmpty) e.key: e.value,
      };
}
